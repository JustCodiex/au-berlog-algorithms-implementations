DELTA = "\x01";
LAMBDA = "\x02";

ACCEPT_STATE = 1;
EMPTY_STACK = 2;
ACCEPT_STATE_EMPTY_STACK = 3;

printf = function(s)
    if s == DELTA then
        return "∆";
    elseif s == LAMBDA then
        return "λ";
    elseif s:len() == 1 then
        return s;
    else
        local msg = "";
        s:gsub(".", function(c) msg = msg.. printf(c) end);
        print(msg);
    end
end

-- Checks if a table contains an element
function has_element(t, e)
    for i=1, #t do
        if t[i] == e then
            return true;
        end
    end
    return false;
end

function table_to_string(t)
    local s = "";
    for i=1, #t do
        s = s..t[i];
    end
    return s;
end

function PDA(states, transitions, accepts, initial, stack)
    local __setuptransitions = function(M)
        local x = {};
        for i=1, #M.Q do
            x[M.Q[i]] = {};
            for k, v in pairs(M.delta) do
                if M.Q[i] == v.from then
                    table.insert(x[M.Q[i]], v);
                end
            end
        end
        M.Q = x;
    end
    if accepts ~= nil and type(accepts) ~= "table" then
        accepts = { accepts };
    end
    local m = {
        Q = states,
        delta = transitions,
        QAccepts = accepts,
        QInitial = initial or "q_0",
        stacksymbol = stack or "Z",
    };
    __setuptransitions(m);
    return m;
end

function Transition(from, to, read, pop, push)
    if type(push) == "string" then
        local temp = {};
        push:gsub(".", function(c) table.insert(temp, c) end);
        push = temp;
    end
    return {
        from = from,
        to = to,
        read = read,
        pop = pop,
        push = push
    };
end

function PeekCheck(stack, e)
    if (stack:peek() == nil and e == LAMBDA) or stack:peek() == e then
        return true;
    else
        return false;
    end
end

function Run(M, input, mode)
    if mode == nil then
        mode = ACCEPT_STATE;
    end
    local stack = dofile("stack.lua");
    stack:push(M.stacksymbol);
    local state = M.QInitial;
    local i = 1;
    local isDone = function()
        local isEmpty = stack:size() == 0;
        local isAccepted = has_element(M.QAccepts, state);
        return (isEmpty and isAccepted and mode == ACCEPT_STATE_EMPTY_STACK ) or
            (isEmpty and mode == EMPTY_STACK) or
            (isAccepted and mode == ACCEPT_STATE) and i + 1 > input:len();
    end
    local inputAccepted = true;
    local iterations = {};
    local iterationsCounter = 1;
    while not isDone() do
        local c = input:sub(i,i);
        local any = false;
        for k,v in pairs(M.Q[state]) do
            if v.from == state and (v.read == c or v.read == LAMBDA) and PeekCheck(stack, v.pop) then
                iterations[iterationsCounter] = {
                    symbol = c,
                    stack = stack:clone(),
                    q = state,
                    p = v.to,
                };
                stack:pop();
                for j=1, #v.push do
                    local val = v.push[#v.push - j + 1];
                    if val ~= LAMBDA then
                        stack:push(val);
                    end
                end
                --print(" "..state.."->"..v.to.." ["..c .."/".. v.pop .. "#" .. stack:size() .."]");
                state = v.to;
                if v.read ~= LAMBDA then
                    i = i + 1;
                end
                any = true;
                break;
            end
        end
        if not any then
            inputAccepted = false;
            break;
        else
            iterationsCounter = iterationsCounter + 1;
        end
    end
    return { result = has_element(M.QAccepts, state) and inputAccepted, input = input, trace = iterations };
end

G_PRINT_STEPS = true; -- set to false to ommit trace

function PrintPDAResults(r)
    printf("PDA Run with input: \""..r.input.."\"");
    print("  Input Accepted: " ..tostring(r.result));
    if G_PRINT_STEPS then
        for k,v in pairs(r.trace) do
            print("   Step "..k .." ("..v.q.."->"..v.p..")");
            printf("    Symbol: "..v.symbol);
            printf("    Stack: "..table_to_string(v.stack));
        end
    end
end

local pda1 = PDA(
    { "q_0", "q_1", "q_2", "q_3" },
    {
        Transition("q_0", "q_1", "a", "Z", "xZ"),
        Transition("q_1", "q_1", "a", "x", "xx"),
        Transition("q_1", "q_2", "b", "x", LAMBDA),
        Transition("q_2", "q_2", "b", "x", LAMBDA),
        Transition("q_2", "q_3", LAMBDA, "Z", LAMBDA),
        Transition("q_2", "q_3", "c", "Z", LAMBDA),
        Transition("q_3", "q_3", "c", LAMBDA, LAMBDA),
    },
    "q_3"
);

PrintPDAResults(Run(pda1, "aabbc"));
PrintPDAResults(Run(pda1, "aabb"));
PrintPDAResults(Run(pda1, "aabbbc"));
PrintPDAResults(Run(pda1, "aaaaaabbbbbbcc"));

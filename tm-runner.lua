DELTA = "\x01";
LAMBDA = "\x02";

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

RIGHT = "R";
LEFT = "L";
STAY = "S";

function Turing(states, transitions, accept, reject, initial)
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
    local m = {
        Q = states,
        delta = transitions,
        QAccepting = accept or "h_a",
        QReject = reject or "h_r",
        QInitial = initial or "q_0",
    };
    __setuptransitions(m);
    return m;
end

function Transition(from, to, read, write, direction)
    local t = {};
    t.from = from;
    t.to = to;
    if type(read) == "string" then
        t.read = { read };
        t.write = { write };
        t.dir = { direction };
    else
        t.read = read;
        t.write = write;
        t.dir = direction;
    end
    return t;
end

function TransitionFromString(from, to, str)
    local read = {};
    local write = {};
    local dir = {};
    local i = 1;
    local j = 1;
    while i < str:len() do
        read[j] = str:sub(i, i);
        if read[j] == "#" then
            read[j] = DELTA;
        end
        write[j] = str:sub(i+2, i+2);
        if write[j] == "#" then
            write[j] = DELTA;
        end
        dir[j] = str:sub(i+3, i+3);
        i = i + 5;
        j = j + 1;
    end
    return Transition(from, to, read, write, dir);
end

function ToCharTable(str)
    local arr = {};
    for i = 1, str:len() do
        arr[i] = str:sub(i, i);
    end
    return arr;
end

function TapeToString(tape)
    local str = "";
    for i=1, #tape do
        str = str .. tape[i];
    end
    return str;
end

function PrintTMResult(r)
    print("TM Result:");
    printf("  Input: " ..r.input);
    printf("  Final Tape: " ..r.output);
    print("  Accepted: " ..tostring(r.accept));
    print("  Terminated: " ..tostring(r.terminated));
    printf("  Path: "..r.path);
end

function Run(M, input, tape)
    local state = M.QInitial;
    if tape == nil then
        tape = { [1] = { pos = 1, tape = ToCharTable("\x01" .. input) }, };
    elseif type(tape) == "number" then
        local count = tape;
        tape = { };
        tape[1] = { pos = 1, tape = ToCharTable("\x01"..input) };
        for i = 2, count do
            tape[i] = { pos = 1, tape = {} };
        end
    end
    local path = state;
    local iteration = 0;
    local terminated = true;
    while state ~= M.QAccepting and state ~= M.QReject do
        iteration = iteration + 1;
        if iteration > input:len() * 100 then
            terminated = false;
            break;
        end
        local wrote = DELTA;
        local dir = "S";
        local char = tape[1].tape[tape[1].pos] or DELTA;
        local any = false;
        for k, v in pairs(M.Q[state]) do
            if v.from == state then
                local isValid = true;
                for i=1, #tape do
                    if not (v.read[i] == (tape[i].tape[tape[i].pos] or DELTA)) then
                        isValid = false;
                        break;
                    end
                end
                if isValid then
                for i=1, #tape do
                    tape[i].tape[tape[i].pos] = v.write[i];
                    if v.dir[i] == RIGHT then
                        tape[i].pos = tape[i].pos + 1;
                    elseif v.dir[i] == LEFT then
                        tape[i].pos = tape[i].pos - 1;
                    end
                    if i == 1 then
                        wrote = v.write[i];
                        dir = v.dir[i];
                    end
                    state = v.to;
                end
                    any = true;
                    break;
                end
            end
        end
        if not any then -- goto h_r
            path = path.. "-["..char.."]->h_r";
            break;
        else
            path = path.. "-["..char.."/" ..wrote.."/".. dir .. "]->"..state;
        end
    end
    if not terminated then path = "Computation failed; last state was " ..state end;
    return { accept = state == M.QAccepting, path = path, terminated = terminated, input = input, output = TapeToString(tape[1].tape) };
end

local TM0 = Turing(
    { "q_0", "q_1", "q_2", "h_a" },
    {
        Transition("q_0", "q_1", DELTA, DELTA, RIGHT),
        Transition("q_1", "q_1", "1", "1", RIGHT),
        Transition("q_1", "q_2", "0", "1", STAY),
        Transition("q_2", "q_2", "1", "1", LEFT),
        Transition("q_2", "h_a", DELTA, DELTA, RIGHT),
    }
);

print("Testing Turing Machine for language \"1*0(0+1)*\"");
PrintTMResult(Run(TM0, "11111011", nil));
PrintTMResult(Run(TM0, "111110011", nil));
PrintTMResult(Run(TM0, "1111101010", nil));
PrintTMResult(Run(TM0, "01111101010", nil));
PrintTMResult(Run(TM0, "1", nil));

local TM1 = Turing(
    { "q_0", "q_1", "q_2", "q_3", "q_4", "q_5", "h_a" },
    {
        Transition("q_0", "q_1", { DELTA, DELTA, DELTA }, { DELTA, DELTA, DELTA }, { RIGHT, STAY, STAY}),
        Transition("q_1", "q_1", { "1", DELTA, DELTA }, { DELTA, DELTA, "1" }, { RIGHT, STAY, RIGHT}),
        Transition("q_1", "q_2", { DELTA, DELTA, DELTA }, { DELTA, DELTA, DELTA }, { RIGHT, STAY, STAY}),
        Transition("q_2", "q_2", { "1", DELTA, DELTA }, { DELTA, "1", DELTA }, { RIGHT, RIGHT, STAY}),
        Transition("q_2", "q_3", { DELTA, DELTA, DELTA }, { DELTA, DELTA, DELTA }, { RIGHT, LEFT, STAY}),
        Transition("q_3", "q_4", { DELTA, "1", DELTA }, { DELTA, DELTA, DELTA }, { STAY, STAY, LEFT}),
        Transition("q_4", "q_4", { DELTA, DELTA, "1" }, { "1", DELTA, "1" }, { RIGHT, STAY, LEFT}),
        Transition("q_4", "q_5", { DELTA, DELTA, DELTA }, { DELTA, DELTA, DELTA }, { STAY, STAY, RIGHT}),
        Transition("q_5", "q_5", { DELTA, DELTA, "1" }, { DELTA, DELTA, "1" }, { STAY, STAY, RIGHT}),
        Transition("q_5", "q_3", { DELTA, DELTA, DELTA }, { DELTA, DELTA, DELTA }, { STAY, LEFT, STAY}),
        Transition("q_3", "h_a", { DELTA, DELTA, DELTA }, { DELTA, DELTA, DELTA }, { STAY, STAY, STAY}),
    }
);

print("");
print("Testing Turing Machine for computation: \"x*y\"");
PrintTMResult(Run(TM1, "111"..DELTA.."1111", 3));

local TM2 = Turing(
    { "q_0", "q_1", "q_2", "q_3", "q_4", "q_5", "h_a" },
    {
        TransitionFromString("q_0", "q_1", "#/#R,#/#S,#/#S"),
        TransitionFromString("q_1", "q_1", "1/#R,#/#S,#/1R"),
        TransitionFromString("q_1", "q_2", "#/#R,#/#S,#/#S"),
        TransitionFromString("q_2", "q_2", "1/#R,#/1R,#/#S"),
        TransitionFromString("q_2", "q_3", "#/#R,#/#L,#/#S"),
        TransitionFromString("q_3", "q_4", "#/#S,1/#S,#/#L"),
        TransitionFromString("q_4", "q_4", "#/1R,#/#S,1/1L"),
        TransitionFromString("q_4", "q_5", "#/#S,#/#S,#/#R"),
        TransitionFromString("q_5", "q_5", "#/#S,#/#S,1/1R"),
        TransitionFromString("q_5", "q_3", "#/#S,#/#L,#/#S"),
        TransitionFromString("q_3", "h_a", "#/#S,#/#S,#/#S"),
    }
);
print("");
print("Testing Turing Machine for computation: \"x*y\" using string interpretation");
PrintTMResult(Run(TM2, "11111"..DELTA.."11", 3));

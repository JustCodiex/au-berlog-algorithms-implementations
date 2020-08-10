function mat(w,h)
    local matrix = {};
    for x = 1, w do
        matrix[x] = {}
        for y = 1, h do
            matrix[x][y] = {};
        end
    end
    return matrix;
end

function has_element(t, e)
    for i=1, #t do
        if t[i] == e then
            return true;
        end
    end
    return false;
end

function prod_rule(g, letter)
    local rules = {};
    for k, v in pairs(g) do
        if has_element(v, letter) then
            table.insert(rules, k);
        end
    end
    return rules;
end

function parse(w, g)
    local n = string.len(w);
    local X = mat(n, n);
    for len=1, n do
        for i = 1, n - len + 1 do
            local j = i + len - 1;
            if len == 1 then
                X[i][j] = prod_rule(g, w:sub(i, i));
            else
                X[i][j] = {};
                for k = i, j - 1 do
                    for r,p in pairs(g) do
                        for u = 1, #p do
                            if has_element(X[i][k], p[u]:sub(1,1)) and has_element(X[k+1][j], p[u]:sub(2,2)) then
                                table.insert(X[i][j], r);
                            end
                        end
                    end
                end
            end
        end
    end
    return X;
end

function printmat(m)
    for i = 1, #m do
        local row = i .. " ";
        for j = 1, #m[i] do
            if i <= j then
                if #m[i][j] == 0 then
                    row = row .. " Ø ";
                else
                    local str = "{";
                    for k=1, #m[i][j] do
                        str = str..m[i][j][k];
                        if k < #m[i][j] then
                            str = str..",";
                        end
                    end
                    str = str .. "}";
                    row = row .. str;
                end
            else
                row = row .. "   ";
            end
        end
        print(row);
    end
end

grammar = {
    ["S"] = { "AT", "AB" },
    ["T"] = { "XB" },
    ["X"] = { "AT", "AB" },
    ["A"] = { "a" },
    ["B"] = { "b" },
}

print("Test 1:");
printmat(parse("aaabbb", grammar));

print("");
print("Test 2:");


grammar = {
    ["S"] = { "SB", "0", "1" },
    ["B"] = { "CS" },
    ["C"] = { "+", "*" },
}

printmat(parse("0+1*0", grammar));

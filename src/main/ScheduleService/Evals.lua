--// Evals \\--
--// SomewhatMay, April 2023 \\--

function Equal(arguemntA, argumentB)
    assert(type(arguemntA) == "number" and type(argumentB) == "number", "Arguemnts are not both numbers!")

    return arguemntA == argumentB
end

function NotEqual(arguemntA, argumentB)
    assert(type(arguemntA) == "number" and type(argumentB) == "number", "Arguemnts are not both numbers!")

    return arguemntA ~= argumentB
end

function GreaterThan(arguemntA, argumentB)
    assert(type(arguemntA) == "number" and type(argumentB) == "number", "Arguemnts are not both numbers!")

    return arguemntA > argumentB
end

function LessThan(arguemntA, argumentB)
    assert(type(arguemntA) == "number" and type(argumentB) == "number", "Arguemnts are not both numbers!")

    return arguemntA < argumentB
end

function GreaterThanOrEqualledTo(arguemntA, argumentB)
    assert(type(arguemntA) == "number" and type(argumentB) == "number", "Arguemnts are not both numbers!")

    return arguemntA >= argumentB
end

function LessThanOrEqualledTo(arguemntA, argumentB)
    assert(type(arguemntA) == "number" and type(argumentB) == "number", "Arguemnts are not both numbers!")

    return arguemntA <= argumentB
end

return {
    [1] = Equal;
    [2] = NotEqual;
    [3] = GreaterThan;
    [4] = LessThan;
    [5] = GreaterThanOrEqualledTo;
    [6] = LessThanOrEqualledTo;
}
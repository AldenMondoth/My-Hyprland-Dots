-- bar.luau
text.title = "ready"
fact.howmany = 3

on("reload", function()
    fact.howmany = (fact.howmany + 1) % 8
end)

every(5000, function() text.title = os.date("%H:%M:%S") end)

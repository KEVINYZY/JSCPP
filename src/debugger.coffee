diffpatch = require('jsondiffpatch').create(null)
Runtime = require "./rt"

Debugger = ->
    @fakeRT = new Runtime()
    @rt = {}
    @snapshots = null
    @i = 0
    @src = ""
    return this

Debugger::next = ->
    if @i >= @snapshots.length
        return false
    @rt = diffpatch.patch(@rt, @snapshots[@i++].diff)
    @fakeRT.types = @rt.types
    @fakeRT.scope = @rt.scope
    @i < @snapshots.length

Debugger::prev = ->
    if @i <= 1
        return false
    @rt = diffpatch.reverse(@rt, @snapshots[--@i].diff)
    @fakeRT.types = @rt.types
    @fakeRT.scope = @rt.scope
    @i > 0

Debugger::output = ->
    @rt.debugOutput or ""

Debugger::nextLine = ->
    if @i >= @snapshots.length
        "<eof>"
    else
        s = @snapshots[@i].stmt
        @src.slice(s.reportedPos, s.pos).trim()

Debugger::nextStmt = ->
    @snapshots[@i].stmt

Debugger::type = (name) ->
    @rt.types[name]

Debugger::variable = (name) ->
    if name
        v = @fakeRT.readVar(name)
        {
            type: @fakeRT.makeTypeString(v.t)
            value: v.v
        }
    else
        for k, v of @fakeRT.scope[@fakeRT.scope.length-1] when typeof v is "object" and "t" of v and "v" of v
                {
                    name: k
                    type: @fakeRT.makeTypeString(v.t)
                    value: v.v
                }


module.exports = Debugger
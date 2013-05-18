core = {};
clipboard = null;
ace = null

core.setAce = (_ace) -> ace = _ace;
core.getText = () -> ace.getValue();
core.insert = (pos, text) -> 
	if typeof pos == "string" && typeof text == "undefined"
		text = pos
		pos = core.getCursorPosition()
	ace.getSession().insert(pos, text);

core.getSelectedRange = () -> ace.getSelectionRange();
core.getCursorPosition = () -> ace.getCursorPosition();
core.setCursorPosition = (pos) -> ace.moveCursorToPosition(pos); ace.clearSelection();
core.getSelectionText = () -> ace.getSession().getTextRange(core.getSelectionRange());
core.clearSelection = () -> ace.clearSelection();

core.cut = () -> clipboard = core.getSelectionText(); ace.execCommand("cut"); return; 
core.copy = () -> clipboard = core.getSelectionText(); return;
core.paste = () -> core.insertAtCursor(clipboard); ace.clearSelection(); return;

core.focus = () -> ace.focus();

core.getLine = (l) -> 
	l = core.getCursorPosition().line if not l?
	ace.getSession().getLine(l);

core.indentToNextLine = (pos) ->
	pos = core.getCursorPosition() if not pos?

	line = core.getLine(pos.line);
	t = line.match /^[\s]*/;
	if t? 
		t = t[0]
	else 
		t = "";
	return if (t.length == line.length);
	core.insert(pos, "\n"+t);

core.getEol = (pos) ->
	pos = core.getCursorPosition() if not pos?
	pos.col = core.getLine(pos.line).length;
	pos

core.searchReverse = (pos, matchStr, callback) ->
	if typeof pos == "string"
		callback = matchStr
		matchStr = pos
		pos = core.getCursorPosition() 

	stop = false;

	matchCallback = (m...) ->
		return if stop
		foundOffset = m[m.length - 2];
		posFound = editor.addPositionOffset(iter.getPos(), foundOffset);
		return if editor.isPositionBefore(pos, posFound);
		if callback(posFound, m) == false
			stop = true;

	for l in [pos.line..0]
		line = core.getLine(l);
		line.replace(matchStr, matchCallback);
		break if stop

core.embbedText = (range, prefix, suffix) ->
	core.insert(range.end, suffix);
	core.insert(range.start, prefix)


console.log(core);

return core;

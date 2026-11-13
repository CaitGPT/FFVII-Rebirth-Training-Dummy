-- Plain Lua 5.4 checks for course_text.lua's key/name matching.
local course_text = require("course_text")

assert(course_text.mode_of("$menu_Colosseum_CourseTitle_COL99_TrainingDummy_DPS") == "DPS", "title key")
assert(course_text.mode_of("$menu_Colosseum_CourseTitle_COL99_TrainingDummy_Heal") == "Heal", "heal key")
-- After the menu shows the readable name, the course is still recognised.
assert(course_text.mode_of(course_text.NAMES.Tank.title) == "Tank", "readable name")
assert(course_text.mode_of("$menu_Colosseum_CourseTitle_COL99_TrainingDummy_Boss") == nil, "unknown mode")
assert(course_text.mode_of("$menu_Colosseum_CourseTitle_COL30_SUMMON_Titan") == nil, "vanilla course")
assert(course_text.mode_of(nil) == nil, "no text")
print("course_text_test: ok")
-- Giving up a course tears the simulator's widgets down and rebuilds them. Replacing text through that window read
-- freed memory and took the game down (2026-11-13 on 1.005), so apply() must stop once the menu it was told about
-- has gone, rather than scanning every text block in the game.
local alive = true
local menu = {IsValid = function() return alive end}
local scans = 0
_G.FindAllOf = function() scans = scans + 1; return {} end

course_text.remember(menu)
assert(course_text.has_work(), "the menu asked for work")
course_text.apply()
assert(course_text.has_work(), "work continues while the menu is alive")

alive = false  -- Give Up tears the menu down under us
course_text.apply()
assert(not course_text.has_work(), "a dead menu drops the work")
local after = scans
course_text.apply()
assert(scans == after, "nothing is scanned once the menu has gone")

alive = true
course_text.remember(menu)
course_text.stop()
assert(not course_text.has_work(), "stop drops the work")

print("course_text_test: teardown guard ok")

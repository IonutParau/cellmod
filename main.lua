--core setup
require("cellmod")

cells = {}
initial = {}
placeables = {}
stilldata = {}	--data that shouldn't follow cells when they are moved
chunks = {}
chunks.all = {}
copycells = {}
undocells,maxundo = {},10
isinitial = true
updatekey = 0
supdatekey = 0
stickkey = 0
chosen = {id=0,rot=0,size=1,shape="Square",mode="All",data={0,0,0,0,0,0,0,0,0,0,0,0,0}}
selection = {on=false,w=0,h=0,x=0,y=0}
copied = {}
pasting = false
openedtab = -1
openedsubtab = nil
placecells = true
width,height = 100,100
newwidth,newheight = 100,100
delay,tpu,volume,svolume,border,uiscale,newuiscale = .2,1,.5,.5,2,1,1
bordercells = {1,41,12,205,51,141,150,151,152,126,176,"wrap"}
cam = {x=0,y=0,tarx=0,tary=0,zoom=20,tarzoom=20,zoomlevel=4}
zoomlevels = {2,4,8,20,40,80,160}
delta,winxm,winym,centerx,centery = 0,1,1,400,300
dtime,itime = 0,0
hudrot,hudlerp = 0,0
paused = false
inmenu = false
puzzle,draggedcell,erasebg = nil, nil, nil
dodebug,subticking,subtick,fancy = false,false,1,true
mobile = true
portals = {}
reverseportals = {}
showinfo = true
title,subtitle = "",""
puzzle = true
clear,winscreen = false,false
level = nil
mainmenu = 1

function math.lerp(a,b,c)
	if c ~= c then return b end	--thanks to lua f*ckery NaN is not equal to NaN
	return a+(b-a)*c
end

function math.graphiclerp(a,b,c)
	if c ~= c or not fancy then return b end
	return a+(b-a)*c
end

function math.round(a)
	return math.floor(a+.5)
end

function math.distSqr(a,b)
	return (a*a+b*b)
end

function table.copy(t)
	local newt = {}
	for k,v in pairs(t) do
		if type(v) == "table" and k ~= "lastvars" and k ~= "eatencells" then v = table.copy(v) end
		newt[k] = v
	end
	return newt
end

function table.merge(t1,t2)
	for k,v in pairs(t2) do
		t1[k] = t1[k] or v
	end
end

function rainbow(a)	--the most important function /s
	return {(math.sin(-love.timer.getTime()))+0.75,(math.sin(-love.timer.getTime()+math.pi*2/3))+0.75,(math.sin(-love.timer.getTime()+math.pi*4/3))+0.75,a}
end

function getempty()
	return {id=0,rot=0,lastvars={0,0,0},vars={}}
end

function Play(aud)
	if aud:tell() > .05 then aud:stop() end
	aud:play()
end

--textures

love.graphics.setDefaultFilter("nearest")

tex = {}
texsize = {}

function NewTex(val,key)
	local p = "textures/" .. val .. ".png"

	if love.filesystem.read(p) == nil then
		p = val
	end

	if key then
		tex[key] = love.graphics.newImage(p)
		texsize[key] = {w=tex[key]:getWidth(),h=tex[key]:getHeight(),w2=tex[key]:getWidth()*.5,h2=tex[key]:getHeight()*.5}
	else
		table.insert(tex,love.graphics.newImage(p))
		texsize[#tex] = {w=tex[#tex]:getWidth(),h=tex[#tex]:getHeight(),w2=tex[#tex]:getWidth()*.5,h2=tex[#tex]:getHeight()*.5}
	end
end

NewTex("bg",0)
NewTex("wall",1)
NewTex("mover",2)
NewTex("generator",3)
NewTex("push",4)
NewTex("slide",5)
NewTex("onedirectional",6)
NewTex("twodirectional",7)
NewTex("threedirectional",8)
NewTex("rotator_cw",9)
NewTex("rotator_ccw",10)
NewTex("rotator_180",11)
NewTex("trash",12)
NewTex("enemy",13)
NewTex("puller",14)
NewTex("mirror",15)
NewTex("diverter",16)
NewTex("redirector",17)
NewTex("gear_cw",18)
NewTex("gear_ccw",19)
NewTex("ungeneratable",20)
NewTex("repulsor",21)
NewTex("weight",22)
NewTex("crossgenerator",23)
NewTex("strongenemy",24)
NewTex("freezer",25)
NewTex("cwgenerator",26)
NewTex("ccwgenerator",27)
NewTex("advancer",28)
NewTex("impulsor",29)
NewTex("flipper",30)
NewTex("bidiverter",31)
NewTex("gate_or",32)
NewTex("gate_and",33)
NewTex("gate_xor",34)
NewTex("gate_nor",35)
NewTex("gate_nand",36)
NewTex("gate_xnor",37)
NewTex("straightdiverter",38)
NewTex("crossdiverter",39)
NewTex("twistgenerator",40)
NewTex("ghost",41)
NewTex("bias",42)
NewTex("shield",43)
NewTex("intaker",44)
NewTex("replicator",45)
NewTex("crossreplicator",46)
NewTex("fungal",47)
NewTex("forker",48)
NewTex("triforker",49)
NewTex("superrepulsor",50)
NewTex("demolisher",51)
NewTex("opposition",52)
NewTex("crossopposition",53)
NewTex("slideopposition",54)
NewTex("supergenerator",55)
NewTex("crossmirror",56)
NewTex("birotator",57)
NewTex("driller",58)
NewTex("auger",59)
NewTex("corkscrew",60)
NewTex("bringer",61)
NewTex("outdirector",62)
NewTex("indirector",63)
NewTex("cw-director",64)
NewTex("ccw-director",65)
NewTex("semirotator_cw",66)
NewTex("semirotator_ccw",67)
NewTex("semirotator_180",68)
NewTex("toughslide",69)
NewTex("pararotator",70)
NewTex("grasper",71)
NewTex("heaver",72)
NewTex("lugger",73)
NewTex("hoister",74)
NewTex("raker",75)
NewTex("borer",76)
NewTex("carrier",77)
NewTex("omnipower",78)
NewTex("ice",79)
NewTex("octomirror",80)
NewTex("grapulsor_cw",81)
NewTex("grapulsor_ccw",82)
NewTex("bivalvediverter",83)	--these come before the normal valves because i had ideas here that didnt work out and i didnt wanna shift more ids so i just replaced them
NewTex("paravalvediverter_cw",84)
NewTex("paravalvediverter_ccw",85)
NewTex("bivalvedisplacer",86)
NewTex("paravalvedisplacer_cw",87)
NewTex("paravalvedisplacer_ccw",88)
NewTex("semiflipper_h",89)
NewTex("semiflipper_v",90)
NewTex("displacer",91)
NewTex("bidisplacer",92)
NewTex("valvediverter_cw",93)
NewTex("valvediverter_ccw",94)
NewTex("valvedisplacer_cw",95)
NewTex("valvedisplacer_ccw",96)
NewTex("cwforker",97)
NewTex("ccwforker",98)
NewTex("divider",99)
NewTex("tridivider",100)
NewTex("cwdivider",101)
NewTex("ccwdivider",102)
NewTex("conditional",103)
NewTex("antiweight",104)
NewTex("transmitter",105)
NewTex("shifter",106)
NewTex("crossshifter",107)
NewTex("minigear_cw",108)
NewTex("minigear_ccw",109)
NewTex("cwcloner",110)
NewTex("ccwcloner",111)
NewTex("locker",112)
NewTex("redirectgenerator",113)
NewTex("nudger",114)
NewTex("slicer",115)
NewTex("markerW",116)
NewTex("markerR",117)
NewTex("markerY",118)
NewTex("markerG",119)
NewTex("markerC",120)
NewTex("markerB",121)
NewTex("markerM",122)
NewTex("crimson",123)
NewTex("warped",124)
NewTex("corruption",125)
NewTex("hallow",126)
NewTex("cancer",127)
NewTex("bacteria",128)
NewTex("bioweapon",129)
NewTex("prion",130)
NewTex("greygoo",131)
NewTex("virus",132)
NewTex("tumor",133)
NewTex("infection",134)
NewTex("pathogen",135)
NewTex("unpushable",136)
NewTex("unpullable",137)
NewTex("ungraspable",138)
NewTex("unswappable",139)
NewTex("toughtwodirectional",140)
NewTex("megademolisher",141)
NewTex("resistance",142)
NewTex("tentative",143)
NewTex("restrictor",144)
NewTex("megashield",145)
NewTex("timewarper",146)
NewTex("timegenerator",147)
NewTex("crosstimewarper",148)
NewTex("life",149)
NewTex("spinnercw",150)
NewTex("spinnerccw",151)
NewTex("spinner180",152)
NewTex("key",153)
NewTex("door",154)
NewTex("crossintaker",155)
NewTex("magnet",156)
NewTex("toughonedirectional",157)
NewTex("toughthreedirectional",158)
NewTex("toughpush",159)
NewTex("missile",160)
NewTex("lifemissile",161)
NewTex("staller",162)
NewTex("bulkenemy",163)
NewTex("swivelenemy",164)
NewTex("storage",165)
NewTex("memory",166)
NewTex("trigenerator",167)
NewTex("bigenerator",168)
NewTex("cwmultigenerator",169)
NewTex("ccwmultigenerator",170)
NewTex("tricloner",171)
NewTex("bicloner",172)
NewTex("cwmulticloner",173)
NewTex("ccwmulticloner",174)
NewTex("transporter",175)
NewTex("tainter",176)
NewTex("superreplicator",177)
NewTex("scissor",178)
NewTex("triscissor",179)
NewTex("multiplier",180)
NewTex("trimultiplier",181)
NewTex("cwscissor",182)
NewTex("ccwscissor",183)
NewTex("cwmultiplier",184)
NewTex("ccwmultiplier",185)
NewTex("spooner",186)
NewTex("trispooner",187)
NewTex("cwspooner",188)
NewTex("ccwspooner",189)
NewTex("compounder",190)
NewTex("tricompounder",191)
NewTex("cwcompounder",192)
NewTex("ccwcompounder",193)
NewTex("gate_imply",194)
NewTex("gate_conimply",195)
NewTex("gate_nimply",196)
NewTex("gate_connimply",197)
NewTex("converter",198)
NewTex("truemover",199)
NewTex("truepuller",200)
NewTex("truedriller",201)
NewTex("truemirror",202)
NewTex("truegear_cw",203)
NewTex("truegear_ccw",204)
NewTex("phantom",205)
NewTex("lluea/move",206)
NewTex("bar",207)
NewTex("diodediverter",208)
NewTex("crossdiodediverter",209)
NewTex("twistdiverter",210)
NewTex("glunkisource",211)
NewTex("glunki",212)
NewTex("toughmover",213)
NewTex("spiritpush",214)
NewTex("spiritslide",215)
NewTex("spiritonedirectional",216)
NewTex("spirittwodirectional",217)
NewTex("spiritthreedirectional",218)
NewTex("acid",219)
NewTex("weakacid",220)
NewTex("portal",221)
NewTex("timerepulsor",222)
NewTex("coin",223)
NewTex("coindiverter",224)
NewTex("toughtrash",225)
NewTex("semitrash",226)
NewTex("conveyorgrapulsor",227)
NewTex("crossconveyorgrapulsor",228)
NewTex("constructor",229)
NewTex("coinextractor",230)
NewTex("silicon",231)
NewTex("gravitizer",232)
NewTex("filter",233)
NewTex("rfire",234)
NewTex("creator",235)
NewTex("inertia",236)
NewTex("transformer",237)
NewTex("crosstransformer",238)
NewTex("player",239)
NewTex("fire",240)
NewTex("megafire",241)
NewTex("fireball",242)
NewTex("megafireball",243)
NewTex("superenemy",244)
NewTex("megarotator_cw",245)
NewTex("megarotator_ccw",246)
NewTex("megarotator_180",247)
NewTex("superimpulsor",248)
NewTex("semisilicon",249)
NewTex("biintaker",250)
NewTex("tetraintaker",251)
NewTex("slime",252)
NewTex("uncuttable",253)
NewTex("cwshifter",254)
NewTex("ccwshifter",255)
NewTex("bishifter",256)
NewTex("trishifter",257)
NewTex("ccwmultishifter",258)
NewTex("cwmultishifter",259)
NewTex("cwrelocator",260)
NewTex("ccwrelocator",261)
NewTex("birelocator",262)
NewTex("trirelocator",263)
NewTex("ccwmultirelocator",264)
NewTex("cwmultirelocator",265)
NewTex("degravitizer",266)
NewTex("transmutator",267)
NewTex("crosstransmutator",268)
NewTex("crasher",269)
NewTex("tugger",270)
NewTex("yanker",271)
NewTex("lifter",272)
NewTex("hauler",273)
NewTex("dragger",274)
NewTex("mincer",275)
NewTex("cutter",276)
NewTex("screwdriver",277)
NewTex("piercer",278)
NewTex("slasher",279)
NewTex("chiseler",280)
NewTex("lacerator",281)
NewTex("carver",282)
NewTex("apeiropower",283)
NewTex("supermover",284)
NewTex("thawer",285)
NewTex("megafreezer",286)
NewTex("semifreezer",287)
NewTex("fragileplayer",288)
NewTex("pullplayer",289)
NewTex("graspplayer",290)
NewTex("drillplayer",291)
NewTex("nudgeplayer",292)
NewTex("fragilepullplayer",293)
NewTex("fragilegraspplayer",294)
NewTex("fragiledrillplayer",295)
NewTex("fragilenudgeplayer",296)
NewTex("sliceplayer",297)
NewTex("fragilesliceplayer",298)
NewTex("quantumenemy",299)
NewTex("trashdiode",300)
NewTex("brokengenerator",301)
NewTex("brokenreplicator",302)
NewTex("remover",303)
NewTex("brokenmover",304)
NewTex("brokenpuller",305)
NewTex("termite_cw",306)
NewTex("termite_ccw",307)
NewTex("minishield",308)
NewTex("microshield",309)
NewTex("unmoveable",310)
NewTex("inclusiveadvancer",311)
NewTex("placeable","placeable")
NewTex("placeableR","placeableR")
NewTex("placeableY","placeableY")
NewTex("placeableG","placeableG")
NewTex("placeableC","placeableC")
NewTex("placeableB","placeableB")
NewTex("placeableP","placeableP")
NewTex("rotatable","rotatable")
NewTex("lluea/move","lluea0")
NewTex("lluea/grab","lluea1")
NewTex("lluea/pull","lluea2")
NewTex("lluea/drill","lluea3")
NewTex("lluea/slice","lluea4")
NewTex("lluea/moveR","lluea0r")
NewTex("lluea/grabR","lluea1r")
NewTex("lluea/pullR","lluea2r")
NewTex("lluea/drillR","lluea3r")
NewTex("lluea/sliceR","lluea4r")
NewTex("lluea/moveL","lluea0l")
NewTex("lluea/grabL","lluea1l")
NewTex("lluea/pullL","lluea2l")
NewTex("lluea/drillL","lluea3l")
NewTex("lluea/sliceL","lluea4l")
NewTex("pixel","pix")
NewTex("sparkle","sparkle")
NewTex("eraser","eraser")
NewTex("nonexistant","X")
NewTex("effects/frozen","frozen")
NewTex("effects/protected","protected")
NewTex("effects/locked","locked")
NewTex("effects/clamped","clamped")
NewTex("effects/latched","latched")
NewTex("effects/sealed","sealed")
NewTex("effects/bolted","bolted")
NewTex("effects/reinforced","reinforced")
NewTex("effects/sticky","sticky")
NewTex("effects/thawed","thawed")
NewTex("effects/coins","coins")
NewTex("effects/grav0","grav0")
NewTex("effects/grav1","grav1")
NewTex("effects/grav2","grav2")
NewTex("effects/grav3","grav3")
NewTex("menubar","menubar")
NewTex("effects/invalidrot","invalidrot")
NewTex("effects/placeableoverlay","placeableoverlay")
NewTex("effects/placeableRoverlay","placeableRoverlay")
NewTex("effects/placeableYoverlay","placeableYoverlay")
NewTex("effects/placeableGoverlay","placeableGoverlay")
NewTex("effects/placeableCoverlay","placeableCoverlay")
NewTex("effects/placeableBoverlay","placeableBoverlay")
NewTex("effects/placeablePoverlay","placeablePoverlay")
NewTex("effects/rotatableoverlay","rotatableoverlay")
NewTex("copy","copy")
NewTex("cut","cut")
NewTex("paste","paste")
NewTex("bigui","bigui")
NewTex("popups","popups")
NewTex("debug","debug")
NewTex("fancy","fancy")
NewTex("subtick","subtick")
NewTex("delete","delete")
NewTex("checkoff","checkoff")
NewTex("checkon","checkon")
NewTex("zoomin","zoomin")
NewTex("zoomout","zoomout")
NewTex("menu","menu")
NewTex("mode","mode")
NewTex("shape","shape")
NewTex("randrot","randrot")
NewTex("menubg","menubg")
NewTex("music","music")
NewTex("select","select")
NewTex("wrap","wrap")
NewTex("add","add")
NewTex("subtract","subtract")
NewTex("puzzle","puzzle")
NewTex("brushup","brushup")
NewTex("brushdown","brushdown")
NewTex("joystick","joystick")
NewTex("joystickbg","joystickbg")
NewTex("logo","logo")

local font = love.graphics.newFont("nokiafc22.ttf",8)
love.graphics.setFont(font)

--cell info

cellinfo = {}
cellinfo[1] = {name="Wall",						desc="Immovable."}
cellinfo[2] = {name="Pusher",					desc="Constantly attempts to push forwards."}
cellinfo[3] = {name="Generator",				desc="Pushes out the cell behind it, from the front"}
cellinfo[4] = {name="Pushable",					desc="Does nothing; Can be moved in any direction."}
cellinfo[5] = {name="Slider",					desc="Can only be moved towards the marked directions."}
cellinfo[6] = {name="One-Directional",			desc="Can only be moved towards the marked directions."}
cellinfo[7] = {name="Two-Directional",			desc="Can only be moved towards the marked directions."}
cellinfo[8] = {name="Three-Directional",		desc="Can only be moved towards the marked directions."}
cellinfo[9] = {name="CW Rotator",				desc="Rotates neighboring cells 90 degrees clockwise."}
cellinfo[10] = {name="CCW Rotator",				desc="Rotates neighboring cells 90 degrees counter-clockwise."}
cellinfo[11] = {name="180 Rotator",				desc="Rotates neighboring cells 180 degrees."}
cellinfo[12] = {name="Trash",					desc="Deletes all cells that go into it."}
cellinfo[13] = {name="Enemy",					desc="Deletes a cell that goes into it, then dies."}
cellinfo[14] = {name="Puller",					desc="Moves forward and pulls cells. Can not push."}
cellinfo[15] = {name="Mirror",					desc="Swaps the two cells it's arrows point to."}
cellinfo[16] = {name="Diverter",				desc="Diverts whatever comes into it through the arrow."}
cellinfo[17] = {name="Redirector",				desc="Sets the rotation of neighboring cells to it's own rotation."}
cellinfo[18] = {name="CW Gear",					desc="Grabs and rotates surrounding cells around itself clockwise. Gets jammed by immovables and other Gears."}
cellinfo[19] = {name="CCW Gear",				desc="Grabs and rotates surrounding cells around itself counter-clockwise. Gets jammed by immovables and other Gears."}
cellinfo[20] = {name="Ungeneratable",			desc="Causes generators to generate nothing but force instead of another Ungeneratable."}
cellinfo[21] = {name="Repulsor",				desc="Applies a pushing force in 4 directions."}
cellinfo[22] = {name="Weight",					desc="Prevents 1 unit of force from being applied."}
cellinfo[23] = {name="Cross Generator",			desc="Two generators combined."}
cellinfo[24] = {name="Strong Enemy",			desc="An enemy that takes two hits to kill."}
cellinfo[25] = {name="Freezer",					desc="Stops the cells adjacent to it from activating."}
cellinfo[26] = {name="CW Generator",			desc="Clockwise-bent Generator."}
cellinfo[27] = {name="CCW Generator",			desc="Counter-clockwise-bent Generator."}
cellinfo[28] = {name="Advancer",				desc="Puller + Pusher."}
cellinfo[29] = {name="Impulsor",				desc="Pulls cells towards it in 4 directions."}
cellinfo[30] = {name="Flipper",					desc="Flips cells on an axis based on it's rotation."}
cellinfo[31] = {name="Bidiverter",				desc="Two Diverters combined."}
cellinfo[32] = {name="OR Gate",					desc="Conditional generator; generates when the condition\n(A or B) is true. Inputs are on it's sides."}
cellinfo[33] = {name="AND Gate",				desc="Conditional generator; generates when the condition\n(A and B) is true. Inputs are on it's sides."}
cellinfo[34] = {name="XOR Gate",				desc="Conditional generator; generates when the condition\n(A != B) is true. Inputs are on it's sides."}
cellinfo[35] = {name="NOR Gate",				desc="Conditional generator; generates when the condition\n(!A and !B) is true. Inputs are on it's sides."}
cellinfo[36] = {name="NAND Gate",				desc="Conditional generator; generates when the condition\n(!A or !B) true. Inputs are on it's sides."}
cellinfo[37] = {name="XNOR Gate",				desc="Conditional generator; generates when the condition\n(A == B) true. Inputs are on it's sides."}
cellinfo[38] = {name="Straight Diverter",		desc="Diverter with no bend."}
cellinfo[39] = {name="Cross Diverter",			desc="Two Straight diverters combined."}
cellinfo[40] = {name="Twist Generator",			desc="Flips the cell that it generates, across the same axis as the arrow."}
cellinfo[41] = {name="Ghost",					desc="Immovable and can not be generated."}
cellinfo[42] = {name="Bias",					desc="Adds to any force going it's direction and subtracts from any force going against it."}
cellinfo[43] = {name="Shield",					desc="Prevents the cells surrounding it from interacting with enemies or being affected by dangerous forces like infection or transformation."}
cellinfo[44] = {name="Intaker",					desc="Pulls cells that are in front of it towards it. The front acts like a trash cell."}
cellinfo[45] = {name="Replicator",				desc="Clones the cell in front of it."}
cellinfo[46] = {name="Cross Replicator",		desc="Two Replicators combined."}
cellinfo[47] = {name="Fungal",					desc="When this cell is pushed, the cell that pushed it will be converted into another Fungal cell."}
cellinfo[48] = {name="Forker",					desc="Like a Diverter that clones the cell."}
cellinfo[49] = {name="Triforker",				desc="Forker with three outputs."}
cellinfo[50] = {name="Super Repulsor",			desc="Pushes cells across infinite distance with infinite force."}
cellinfo[51] = {name="Demolisher",				desc="Similar to a trash cell, but when a cell is pushed in, the demolisher destroys it's neighbors."}
cellinfo[52] = {name="Opposition",				desc="Can only be pushed, pulled, or grasped towards certain directions, indicated by the arrows."}
cellinfo[53] = {name="Cross Opposition",		desc="Two oppositions combined."}
cellinfo[54] = {name="Slider Opposition",		desc="Opposition that only restricts two sides, while the others are pushable."}
cellinfo[55] = {name="Super Generator",			desc="A generate that generates the entire row of cells behind it."}
cellinfo[56] = {name="Cross Mirror",			desc="Two mirrors combined."}
cellinfo[57] = {name="Birotator",				desc="Rotates CW on one half and CCW on the other half."}
cellinfo[58] = {name="Driller",					desc="Attempts to swaps the cell in front of it with itself."}
cellinfo[59] = {name="Auger",					desc="Driller + Pusher.\nAttempts to push before drilling."}
cellinfo[60] = {name="Corkscrew",				desc="Driller + Puller + Pusher."}
cellinfo[61] = {name="Bringer",					desc="Driller + Puller."}
cellinfo[62] = {name="Outwards Redirector",		desc="Forces neighboring cells to face away from itself."}
cellinfo[63] = {name="Inwards Redirector",		desc="Forces neighboring cells to face towards itself."}
cellinfo[64] = {name="CW Redirector",			desc="Forces neighboring cells to face clockwise around itself."}
cellinfo[65] = {name="CCW Redirector",			desc="Forces neighboring cells to face counter-clockwise around itself."}
cellinfo[66] = {name="CW Semirotator",			desc="Only rotates on 2 faces."}
cellinfo[67] = {name="CCW Semirotator",			desc="Only rotates on 2 faces."}
cellinfo[68] = {name="180 Semirotator",			desc="Only rotates on 2 faces."}
cellinfo[69] = {name="Tough Slider",			desc="Acts like a wall on 2 sides and like a push on the other 2."}
cellinfo[70] = {name="Pararotator",				desc="Rotates CW on two sides and CCW on the other two sides."}
cellinfo[71] = {name="Grasper",					desc="Drags the cells to it's sides along with it."}
cellinfo[72] = {name="Heaver",					desc="Grasper + Pusher."}
cellinfo[73] = {name="Lugger",					desc="Puller + Grasper."}
cellinfo[74] = {name="Hoister",					desc="Puller + Grasper + Pusher."}
cellinfo[75] = {name="Raker",					desc="Driller + Grasper."}
cellinfo[76] = {name="Borer",					desc="Grasper + Pusher + Driller."}
cellinfo[77] = {name="Carrier",					desc="Puller + Grasper + Driller."}
cellinfo[78] = {name="Omnipower",				desc="Puller + Grasper + Pusher + Driller."}
cellinfo[79] = {name="Ice",						desc="Causes cells to slip past when they move near it."}
cellinfo[80] = {name="Octo-Mirror",				desc="4 mirrors combined."}
cellinfo[81] = {name="CW Grapulsor",			desc="Applies clockwise grasping force to it's neighbors."}
cellinfo[82] = {name="CCW Grapulsor",			desc="Applies counter-clockwise grasping force to it's neighbors."}
cellinfo[83] = {name="Bivalve Diverter",		desc="Valve Diverter with three inputs."}
cellinfo[84] = {name="CW Paravalve Diverter",	desc="Straight Diverter with two extra curved inputs."}
cellinfo[85] = {name="CCW Paravalve Diverter",	desc="Straight Diverter with two extra curved inputs."}
cellinfo[86] = {name="Bivalve Displacer",		desc="Bivalve Diverter that doesn't rotate cells."}
cellinfo[87] = {name="CW Paravalve Displacer",	desc="CW Paravalve Diverter that doesn't rotate cells."}
cellinfo[88] = {name="CCW Paravalve Displacer",	desc="CCW Paravalve Diverter that doesn't rotate cells."}
cellinfo[89] = {name="Semiflipper A",			desc="Only flips on 2 sides."}
cellinfo[90] = {name="Semiflipper B",			desc="Only flips on 2 sides."}
cellinfo[91] = {name="Displacer",				desc="Diverter that doesn't rotate cells."}
cellinfo[92] = {name="Bidisplacer",				desc="Bidiverter that doesn't rotate cells."}
cellinfo[93] = {name="CW Valve Diverter",		desc="One-way Diverter with two input faces."}
cellinfo[94] = {name="CCW Valve Diverter",		desc="One-way Diverter with two input faces."}
cellinfo[95] = {name="CW Valve Displacer",		desc="CW Valve Diverter that doesn't rotate cells."}
cellinfo[96] = {name="CCW Valve Displacer",		desc="CCW Valve Diverter that doesn't rotate cells."}
cellinfo[97] = {name="CW Forker",				desc="Forker with a straight and rotated output."}
cellinfo[98] = {name="CCW Forker",				desc="Forker with a straight and rotated output."}
cellinfo[99] = {name="Divider",					desc="Forker that doesn't rotate cells."}
cellinfo[100] = {name="Tridivider",				desc="Triforker that doesn't rotate cells."}
cellinfo[101] = {name="CW Divider",				desc="CW Forker that doesn't rotate cells."}
cellinfo[102] = {name="CCW Divider",			desc="CCW Forker that doesn't rotate cells."}
cellinfo[103] = {name="Conditional",			desc="The weight of this cell depends on it's rotation.\n(0-3, increases clockwise)"}
cellinfo[104] = {name="Anti-Weight",			desc="Adds 1 unit of force to applied forces."}
cellinfo[105] = {name="Transmitter",			desc="When rotated, flipped, or given an effect such as protection, it applies the effects to it's neighbors aswell."}
cellinfo[106] = {name="Shifter",				desc="Pulls cells in from the back and pushes them out the front."}
cellinfo[107] = {name="Cross Shifter",			desc="Two Shifters combined."}
cellinfo[108] = {name="CW Minigear",			desc="CW Gear that only affects 4 cells."}
cellinfo[109] = {name="CCW Minigear",			desc="CCW Gear that only affects 4 cells."}
cellinfo[110] = {name="CW Cloner",				desc="CW Generator that does not rotate the generated cell."}
cellinfo[111] = {name="CCW Cloner",				desc="CCW Generator that does not rotate the generated cell."}
cellinfo[112] = {name="Locker",					desc="Prevents the cells adjacent to it from being rotated or flipped."}
cellinfo[113] = {name="Redirect Generator",		desc="Generator that rotates the generated cell so it faces the same way as itself."}
cellinfo[114] = {name="Nudger",					desc="Moves forward, but does not push cells."}
cellinfo[115] = {name="Slicer",					desc="Moves forward; upon hitting a cell, it will attempt to push the cell out of the way in a direction perpendicular to it's own."}
cellinfo[116] = {name="White Marker",			desc="Decoration. Transparent to cells; disappears after being moved onto."}
cellinfo[117] = {name="Red Marker",				desc="Decoration. Transparent to cells; disappears after being moved onto."}
cellinfo[118] = {name="Yellow Marker",			desc="Decoration. Transparent to cells; disappears after being moved onto."}
cellinfo[119] = {name="Green Marker",			desc="Decoration. Transparent to cells; disappears after being moved onto."}
cellinfo[120] = {name="Cyan Marker",			desc="Decoration. Transparent to cells; disappears after being moved onto."}
cellinfo[121] = {name="Blue Marker",			desc="Decoration. Transparent to cells; disappears after being moved onto."}
cellinfo[122] = {name="Purple Marker",			desc="Decoration. Transparent to cells; disappears after being moved onto."}
cellinfo[123] = {name="Crimson",				desc="Turns adjacent cells into Crimson cells."}
cellinfo[124] = {name="Warped",					desc="Turns diagonally adjacent cells into Warped cells."}
cellinfo[125] = {name="Corruption",				desc="Turns surrounding cells into Corruption cells."}
cellinfo[126] = {name="Hallow",					desc="Immovable. When a cell tries to push it, it turns into a another Hallow."}
cellinfo[127] = {name="Cancer",					desc="Similar to Crimson, but can spread onto air cells."}
cellinfo[128] = {name="Bacteria",				desc="Similar to Crimson, but can ONLY spread onto air cells."}
cellinfo[129] = {name="Bioweapon",				desc="Similar to Warped, but can spread onto air cells."}
cellinfo[130] = {name="Prion",					desc="Similar to Warped, but can ONLY spread onto air cells."}
cellinfo[131] = {name="Grey Goo",				desc="Similar to Corruption, but can spread onto air cells."}
cellinfo[132] = {name="Virus",					desc="Similar to Corruption, but can ONLY spread onto air cells."}
cellinfo[133] = {name="Tumor",					desc="Similar to Bacteria, but only spreads 50% of the time."}
cellinfo[134] = {name="Infection",				desc="Similar to Crimson, but only spreads 50% of the time."}
cellinfo[135] = {name="Pathogen",				desc="Similar to Cancer, but only spreads 50% of the time."}
cellinfo[136] = {name="Clamper",				desc="Prevents cells from being pushed."}
cellinfo[137] = {name="Latcher",				desc="Prevents cells from being pulled."}
cellinfo[138] = {name="Sealer",					desc="Prevents cells from being grasped."}
cellinfo[139] = {name="Bolter",					desc="Prevents cells from being swapped."}
cellinfo[140] = {name="Tough Two-Directional",	desc="Acts like a wall on 2 sides (+1 corner) and like a push on the other 2."}
cellinfo[141] = {name="Megademolisher",			desc="Similar to a Demolisher, but affects diagonal neighbors too."}
cellinfo[142] = {name="Resistance",				desc="Can only be pushed with 1 unit of force,"}
cellinfo[143] = {name="Tentative",				desc="Like Resistance, but the amount of force it needs is dependant on it's rotation.\n(1-4, increases clockwise)"}
cellinfo[144] = {name="Restrictor",				desc="Only allows 1 unit of force to pass through."}
cellinfo[145] = {name="Megashield",				desc="Like a Shield, but affects a 5x5 area."}
cellinfo[146] = {name="Timewarper",				desc="Reverts the cell it's pointing at back to what it was in the initial state."}
cellinfo[147] = {name="Time Generator",			desc="Generates whatever the cell behind it was in the initial state."}
cellinfo[148] = {name="Cross Timewarper",		desc="Two Timewarpers in one."}
cellinfo[149] = {name="Life",					desc="Spreads like Conway's Game of Life. Infects non-Life cells."}
cellinfo[150] = {name="CW Spinner",				desc="Immovable. When a cell touches it, it rotates the cell clockwise."}
cellinfo[151] = {name="CCW Spinner",			desc="Immovable. When a cell touches it, it rotates the cell counter-clockwise."}
cellinfo[152] = {name="180 Spinner",			desc="Immovable. When a cell touches it, it rotates the cell 180 degrees."}
cellinfo[153] = {name="Key",					desc="When it gets pushed into a Door cell, it destroys itself and the Door."}
cellinfo[154] = {name="Door",					desc="Immovable, but when a Key cell is pushed into it they destroy eachother."}
cellinfo[155] = {name="Cross Intaker",			desc="Two Intakers combined."}
cellinfo[156] = {name="Magnet",					desc="Magnets can attract or repel each other. Same colors repel, different colors attract."}
cellinfo[157] = {name="Tough One-Directional",	desc="Acts like a wall on 3 sides and like a push on one."}
cellinfo[158] = {name="Tough Three-Directional",desc="Acts like a wall on 1 side (+2 corners) and like a push on the other 3."}
cellinfo[159] = {name="Tough Pushable",			desc="Can't be affected by cells diagonally."}
cellinfo[160] = {name="Missile",				desc="Like a moving enemy."}
cellinfo[161] = {name="Life Missile",			desc="Upon hitting something, it turns into a Life cell."}
cellinfo[162] = {name="Staller",				desc="Like a Wall, but upon collision, it will be destroyed."}
cellinfo[163] = {name="Bulk Enemy",				desc="Like an Enemy, but it will also stop force similar to a Wall.\nIn other words, a Staller that also destroys the pusher."}
cellinfo[164] = {name="Swivel Enemy",			desc="The HP of this enemy is measured by it's rotation.\n(1-4, increases clockwise)"}
cellinfo[165] = {name="Storage",				desc="If a cell moves into it, it will store the cell until another cell bumps it out."}
cellinfo[166] = {name="Memory",					desc="Like a Generator, but once it sees a cell it will generate that cell infinitely until it sees another. If it gets pushed on the top or bottom, it will forget what it was generating."}
cellinfo[167] = {name="Trigenerator",			desc="Generator that generates three cells at once."}
cellinfo[168] = {name="Bigenerator",			desc="Generator that generates two cells at once."}
cellinfo[169] = {name="CW Multigenerator",		desc="Generator that generates two cells at once."}
cellinfo[170] = {name="CCW Multigenerator",		desc="Generator that generates two cells at once."}
cellinfo[171] = {name="Tricloner",				desc="Trigenerator that doesn't rotate the generated cell."}
cellinfo[172] = {name="Bicloner",				desc="Bigenerator that doesn't rotate the generated cell."}
cellinfo[173] = {name="CW Multicloner",			desc="CW Multigenerator that doesn't rotate the generated cell."}
cellinfo[174] = {name="CCW Multicloner",		desc="CCW Multigenerator that doesn't rotate the generated cell."}
cellinfo[175] = {name="Transporter",			desc="Like a Storage cell, but once it holds a cell, it will act like a nudger, then release the cell when it hits a wall. The direction it releases it will be favored towards the rotation of the stored cell, but it will always be perpendicular to the Transporter's direction."}
cellinfo[176] = {name="Tainter",				desc="Like a Trash cell, but when it eats a cell it spreads in the direction that the cell came from."}
cellinfo[177] = {name="Super Replicator",		desc="Like a Replicator, but it replicates the entire row of cells in front of it."}
cellinfo[178] = {name="Scissor",				desc="Upon hitting a cell, it will attempt to split the cell in two and push it out it's sides."}
cellinfo[179] = {name="Triscissor",				desc="Scissor with three outputs."}
cellinfo[180] = {name="Multiplier",				desc="Scissor that doesn't rotate split cells."}
cellinfo[181] = {name="Trimultiplier",			desc="Triscissor that doesn't rotate split cells."}
cellinfo[182] = {name="CW Scissor",				desc="Scissor with a straight and curved output."}
cellinfo[183] = {name="CCW Scissor",			desc="Scissor with a straight and curved output."}
cellinfo[184] = {name="CW Multiplier",			desc="CW Scissor that doesn't rotate split cells."}
cellinfo[185] = {name="CCW Multiplier",			desc="CCW Scissor that doesn't rotate split cells."}
cellinfo[186] = {name="Spooner",				desc="Like a reversed Forker; if multiple cells go in, only one cell comes out."}
cellinfo[187] = {name="Trispooner",				desc="Spooner with three inputs."}
cellinfo[188] = {name="CW Spooner",				desc="Spooner with a straight and curved input."}
cellinfo[189] = {name="CCW Spooner",			desc="Spooner with a straight and curved input."}
cellinfo[190] = {name="Compounder",				desc="Spooner that doesn't rotate cells."}
cellinfo[191] = {name="Tricompounder",			desc="Trispooner that doesn't rotate cells."}
cellinfo[192] = {name="CW Compounder",			desc="CW Spooner that doesn't rotate cells."}
cellinfo[193] = {name="CCW Compounder",			desc="CCW Spooner that doesn't rotate cells."}
cellinfo[194] = {name="IMPLY Gate",				desc="Conditional generator; generates when the condition\n(!A or B) is true. Inputs are on it's sides."}
cellinfo[195] = {name="CON-IMPLY Gate",			desc="Conditional generator; generates when the condition\n(A or !B) is true. Inputs are on it's sides."}
cellinfo[196] = {name="NIMPLY Gate",			desc="Conditional generator; generates when the condition\n(A and !B) is true. Inputs are on it's sides."}
cellinfo[197] = {name="CON-NIMPLY Gate",		desc="Conditional generator; generates when the condition\n(!A and B) is true. Inputs are on it's sides."}
cellinfo[198] = {name="Converter",				desc="When a cell enters for the first time, the Converter stores the cell. The next time a cell enters, it will be converted into the stored cell."}
cellinfo[199] = {name="True Pusher",			desc="Unbreakable Pusher that cannot be stopped."}
cellinfo[200] = {name="True Puller",			desc="Unbreakable Puller that cannot be stopped."}
cellinfo[201] = {name="True Driller",			desc="Unbreakable Driller that cannot be stopped."}
cellinfo[202] = {name="True Mirror",			desc="Unbreakable Mirror that cannot be stopped."}
cellinfo[203] = {name="True CW Gear",			desc="Unbreakable CW Gear that cannot be stopped."}
cellinfo[204] = {name="True CCW Gear",			desc="Unbreakable CCW Gear that cannot be stopped."}
cellinfo[205] = {name="Phantom",				desc="Trash that cannot be generated."}
cellinfo[206] = {name="Lluea",					desc="A pusher with AI. Turns when it hits a wall, dies and turns into it's non-living equivalent if it cannot turn. Llueas will also eat infectious cells, and either reproduce or gain another force when doing so."}
cellinfo[207] = {name="Bar",					desc="When pushed or pulled, it will attempt to grasp the cells at it's sides."}
cellinfo[208] = {name="Diode Diverter",			desc="One-way Straight Diverter."}
cellinfo[209] = {name="Crossdiode Diverter",	desc="One-way Cross Diverters."}
cellinfo[210] = {name="Twist Diverter",			desc="Like a Straight Diverter, but it flips the cell that goes through it like a Twist Generator."}
cellinfo[211] = {name="Glunki",					desc="Creates trails to bring cells to itself and digest them, which takes 25 ticks each cell. If a Glunki is enveloped by the Protection effect or goes 250 ticks with no food, it dies and releases the cell. Glunki trails cannot go too far or control is lost."}
cellinfo[212] = {name="Glunki Trail",			desc="Glunki trail."}
cellinfo[213] = {name="Tough Pusher",			desc="Pusher but unbreakable from the sides."}
cellinfo[214] = {name="Spirit Pushable",		desc="Pushable that cannot be generated."}
cellinfo[215] = {name="Spirit Slider",			desc="Slider that cannot be generated."}
cellinfo[216] = {name="Spirit One-Directional",	desc="One-Directional that cannot be generated."}
cellinfo[217] = {name="Spirit Two-Directional",	desc="Two-Directional that cannot be generated."}
cellinfo[218] = {name="Spirit Three-Directional",desc="Three-Directional that cannot be generated."}
cellinfo[219] = {name="Acid",					desc="Pushable, but when pushed into a cell it destroys it."}
cellinfo[220] = {name="Weak Acid",				desc="One-use Acid."}
cellinfo[221] = {name="Portal",					desc="Portal. Has an ID and a Target ID. Anything that goes in a portal will come out a portal with the same ID as the entrance portals Target ID."}
cellinfo[222] = {name="Time Repulsor",			desc="Repulses cells 1 tick after they get near it."}
cellinfo[223] = {name="Coin",					desc="Adds 1 to a cell's coin count."}
cellinfo[224] = {name="Coin Diverter",			desc="Acts like a Cross Diverter to cells with enough coins, acts like a Wall otherwise. Also subtracts that amount of coins from the cell when they pass through."}
cellinfo[225] = {name="Tough Trash",			desc="Acts like a Trash on two sides and a Wall on the others."}
cellinfo[226] = {name="Semitrash",				desc="Acts like a Trash on two sides and a Pushable on the others."}
cellinfo[227] = {name="Conveyor Grapulsor",		desc="Grapulsor but... well, the arrows explain it."}
cellinfo[228] = {name="Cross Conveyor Grapulsor",desc="Two conveyor grapulsors."}
cellinfo[229] = {name="Constructor",			desc="Like a wall, but when a cell touches the backside it generates it out the front."}
cellinfo[230] = {name="Coin Extractor",			desc="Extracts coins from cells."}
cellinfo[231] = {name="Silicon",				desc="Sticks to other silicon cells.\n(Note that stickiness doesn't work perfectly with pulling and grasping...)"}
cellinfo[232] = {name="Gravitizer",				desc="Causes cells near it to start falling in the direction it's pointing in."}
cellinfo[233] = {name="Filter",					desc="Like a Straight Diverter, but insert a cell on the top or bottom, and it will delete any cell with the same ID."}
cellinfo[234] = {name="Realistic Fire",			desc="Spreads randomly onto nearby cells, floats around randomly, and dies after a random amount of time. Just fun to watch."}
cellinfo[235] = {name="Creator",				desc="Creates the stored cell in all 4 directions.\n(Click to insert cell)"}
cellinfo[236] = {name="Inertia",				desc="Stores momentum. Loses it when hitting a wall."}
cellinfo[237] = {name="Transfomer",				desc="Transforms the cell in front of it into the cell behind it."}
cellinfo[238] = {name="Cross Transformer",		desc="Two Transformers combined."}
cellinfo[239] = {name="Player",					desc="When unpaused, controlled with the arrow keys or WASD."}
cellinfo[240] = {name="Fire",					desc="Spreads onto adjacent cells and dies after a tick."}
cellinfo[241] = {name="Megafire",				desc="Like fire, but affects diagonal neighbors too."}
cellinfo[242] = {name="Fireball",				desc="Moving Fire."}
cellinfo[243] = {name="Megafireball",			desc="Moving Megafire."}
cellinfo[244] = {name="Super Enemy",			desc="Enemy with infinite health; effectively a trash cell that can't delete protected cells."}
cellinfo[245] = {name="CW Megarotator",			desc="CW Rotator that affects diagonal neighbors too."}
cellinfo[246] = {name="CCW Megarotator",		desc="CCW Rotator that affects diagonal neighbors too."}
cellinfo[247] = {name="180 Megarotator",		desc="180 Rotator that affects diagonal neighbors too."}
cellinfo[248] = {name="Super Impulsor",			desc="Pulls cells towards it from infinite distance with infinite force."}
cellinfo[249] = {name="Semisilicon",			desc="Only acts like a silicon on 2 sides."}
cellinfo[250] = {name="Biintaker",				desc="Two combined opposite-sided Intakers."}
cellinfo[251] = {name="Tetraintaker",			desc="Intaker in all four directions."}
cellinfo[252] = {name="Slime",					desc="Causes nearby cells to stick to each other like Silicon.\nNote: Stuck forcers or movers might have trouble propertly exerting force."}
cellinfo[253] = {name="Gluer",					desc="Prevents cells from being scissored."}
cellinfo[254] = {name="CW Shifter",				desc="Clockwise-bent Shifter."}
cellinfo[255] = {name="CCW Shifter",			desc="Counter-clockwise-bent Shifter."}
cellinfo[256] = {name="Bishifter",				desc="Shifter that outputs two cells at once."}
cellinfo[257] = {name="Trishifter",				desc="Shifter that outputs three cells at once."}
cellinfo[258] = {name="CCW Multishifter",		desc="Shifter that outputs two cells at once."}
cellinfo[259] = {name="CW Multishifter",		desc="Shifter that outputs two cells at once."}
cellinfo[260] = {name="CW Relocator",			desc="CCW Shifter that does not rotate the outputted cell."}
cellinfo[261] = {name="CCW Relocator",			desc="CW Shifter that does not rotate the outputted cell."}
cellinfo[262] = {name="Birelocator",			desc="Bishifter that doesn't rotate the outputted cell."}
cellinfo[263] = {name="Trirelocator",			desc="Trishifter that doesn't rotate the outputted cell."}
cellinfo[264] = {name="CCW Multirelocator",		desc="CW Multishifter that doesn't rotate the outputted cell."}
cellinfo[265] = {name="CW Multirelocator",		desc="CCW Multishifter that doesn't rotate the outputted cell."}
cellinfo[266] = {name="Degravitizer",			desc="Un-gravitizes cells."}
cellinfo[267] = {name="Transmutator",			desc="Like a Transformer combined with a Shifter."}
cellinfo[268] = {name="Cross Transmutator",		desc="Two Transmutators combined."}
cellinfo[269] = {name="Crasher",				desc="Pusher + Slicer.\nAttempts to push before slicing."}
cellinfo[270] = {name="Tugger",					desc="Puller + Slicer."}
cellinfo[271] = {name="Yanker",					desc="Puller + Pusher + Slicer."}
cellinfo[272] = {name="Lifter",					desc="Grasper + Slicer."}
cellinfo[273] = {name="Hauler",					desc="Grasper + Pusher + Slicer."}
cellinfo[274] = {name="Dragger",				desc="Puller + Grasper + Slicer."}
cellinfo[275] = {name="Mincer",					desc="Puller + Grasper + Pusher + Slicer."}
cellinfo[276] = {name="Cutter",					desc="Driller + Slicer.\nAttempts to slice before drilling."}
cellinfo[277] = {name="Screwdriver",			desc="Driller + Pusher + Slicer.\nAttempts to push, then slice, then drill."}
cellinfo[278] = {name="Piecer",					desc="Driller + Puller + Slicer."}
cellinfo[279] = {name="Slasher",				desc="Driller + Puller + Pusher + Slicer."}
cellinfo[280] = {name="Chiseler",				desc="Driller + Grasper + Slicer."}
cellinfo[281] = {name="Lacerator",				desc="Driller + Grasper + Pusher + Slicer."}
cellinfo[282] = {name="Carver",					desc="Driller + Puller + Grasper + Slicer."}
cellinfo[283] = {name="Apeiropower",			desc="Driller + Puller + Grasper + Pusher + Slicer."}
cellinfo[284] = {name="Super Pusher",			desc="A pusher with infinite force that moves infinitely fast."}
cellinfo[285] = {name="Thawer",					desc="Prevents cells from being frozen."}
cellinfo[286] = {name="Megafreezer",			desc="Freezes diagonal neighbors as well."}
cellinfo[287] = {name="Semifreezer",			desc="Only freezes 2 neighbors."}
cellinfo[288] = {name="Fragile Player",			desc="A player that acts like an enemy."}
cellinfo[289] = {name="Puller Player",			desc="A player that pulls."}
cellinfo[290] = {name="Grasper Player",			desc="A player that grasps."}
cellinfo[291] = {name="Driller Player",			desc="A player that drills."}
cellinfo[292] = {name="Nudger Player",			desc="A player that cannot push."}
cellinfo[293] = {name="Fragile Puller Player",	desc="A player that pulls and acts like an enemy."}
cellinfo[294] = {name="Fragile Grasper Player",	desc="A player that grasps and acts like an enemy."}
cellinfo[295] = {name="Fragile Driller Player",	desc="A player that drills and acts like an enemy."}
cellinfo[296] = {name="Fragile Nudger Player",	desc="A player that cannot push and acts like an enemy."}
cellinfo[297] = {name="Slicer Player",			desc="A player that slices."}
cellinfo[298] = {name="Fragile Slicer Player",	desc="A player that slices and acts like an enemy."}
cellinfo[299] = {name="Quantum Enemy",			desc="When killed, all Quantum Enemies of the same ID are destroyed as well."}
cellinfo[300] = {name="Deleter Diode Diverter",	desc="Diode Diverter that acts like a Trash cell on the front."}
cellinfo[301] = {name="Broken Generator",		desc="Generator that can only be used once; destroyed after usage."}
cellinfo[302] = {name="Broken Replicator",		desc="Replicator that can only be used once; destroyed after usage."}
cellinfo[303] = {name="Remover",				desc="Pusher that tries to delete the cell in front of it before moving. Cannot delete protected cells."}
cellinfo[304] = {name="Broken Mover",			desc="Pusher that dies once it pushes a cell."}
cellinfo[305] = {name="Broken Puller",			desc="Puller that dies once it pulls a cell."}
cellinfo[306] = {name="CW Termite",				desc="Attempts to move around walls."}
cellinfo[307] = {name="CCW Termite",			desc="Attempts to move around walls."}
cellinfo[308] = {name="Minishield",				desc="Like a Shield, but only affects adjacent neighbors."}
cellinfo[309] = {name="Microshield",			desc="Only protects itself."}
cellinfo[310] = {name="Immobilizer",			desc="Prevents cells from being pushed, pulled, grasped, swapped, or scissored."}
cellinfo[311] = {name="Inclusive Advancer",		desc="Only moves if it can both push and pull."}
cellinfo.placeable = {name="Placeable",			desc="Allows you to drag the cell on top of it to any other Placeable of the same color when in Puzzle Mode."}
cellinfo.placeableR = {name="Red Placeable",	desc="Allows you to drag the cell on top of it to any other Placeable of the same color when in Puzzle Mode."}
cellinfo.placeableY = {name="Yellow Placeable",	desc="Allows you to drag the cell on top of it to any other Placeable of the same color when in Puzzle Mode."}
cellinfo.placeableG = {name="Green Placeable",	desc="Allows you to drag the cell on top of it to any other Placeable of the same color when in Puzzle Mode."}
cellinfo.placeableC = {name="Cyan Placeable",	desc="Allows you to drag the cell on top of it to any other Placeable of the same color when in Puzzle Mode."}
cellinfo.placeableB = {name="Blue Placeable",	desc="Allows you to drag the cell on top of it to any other Placeable of the same color when in Puzzle Mode."}
cellinfo.placeableP = {name="Purple Placeable",	desc="Allows you to drag the cell on top of it to any other Placeable of the same color when in Puzzle Mode."}
cellinfo.rotatable = {name="Rotatable",			desc="Allows you to rotate the cell on top of it by clicking on it when in Puzzle Mode."}
cellinfo.wrap = {name="Wrap",					desc="Seeing this description in-game either means something has gone wrong, or the creator of the mod you're playing is just dumb."}
cellinfo.eraser = {name="Eraser",				desc="Erases cells. You can also right-click to use the eraser.", idadded=true}
cellinfo.mode = {name="Editing Mode",			desc="Changes the editing mode.\nCurrent mode: All", idadded=true}
cellinfo.shape = {name="Brush Shape",			desc="Changes the brush shape.\nCurrent shape: Square", idadded=true}
cellinfo.randrot = {name="Random Rotation",		desc="Testing tool.\nDisabled", idadded=true}
cellinfo.select = {name="Select",				desc="Toggles the select tool.", idadded=true}

bgsprites = love.graphics.newSpriteBatch(tex[0])

--buttons (and cell list) setup

buttons = {}
buttonorder = {}
hoveredbutton = nil

--note that x and y will flip which direction they go towards depending on alignment (they increase away from the sides that the button is aligned to; if centered, goes right and down)
function NewButton(x,y,w,h,icon,key,name,desc,onclick,ishold,enabledwhen,alignment,rot,color,hovercolor,clickcolor)
	color = color or {1,1,1,.5}
	hovercolor = hovercolor or {1,1,1,1}
	clickcolor = clickcolor or {.5,.5,.5,1}
	local halign = (alignment == "bottomleft" or alignment == "left" or alignment == "topleft") and -1 or (alignment == "bottomright" or alignment == "right" or alignment == "topright") and 1 or 0
	local valign = (alignment == "topleft" or alignment == "top" or alignment == "topright") and -1 or (alignment == "bottomleft" or alignment == "bottom" or alignment == "bottomright") and 1 or 0
	local button = {x=x,y=y,w=w,h=h,rot=rot,icon=icon,name=name,desc=desc,onclick=onclick,ishold=ishold,isenabled=enabledwhen or function() return true end,halign=halign,valign=valign,color=color,hovercolor=hovercolor,clickcolor=clickcolor}
	if not buttons[key] then table.insert(buttonorder,key) end
	buttons[key] = button
	return button
end

lists = {}
lists[0] = {name = "Tools", cells = {max=99,"eraser","mode","shape","randrot",{name = "Markers",116,117,118,119,120,121,122}}, desc = "Helpful tools to make editing the world easier.", icon = "eraser"}
lists[1] = {name = "Basic", cells = {max=4,{name = "Walls",max=3,1,41,126,150,151,152,229,235,154,162,224},{name = "Pushables",max=5,4,5,6,7,8,159,69,157,140,158,214,215,216,217,218},{name = "Oppositions",52,53,54},{name = "Weights",max=4,22,103,144,104,42,142,143},{name = "Sticky",207,231,249,252}}, desc = "Basic cells.", icon = 4}
lists[2] = {name = "Movers", cells = {max=4,{name = "Pushers",2,28,72,74,59,60,76,78,269,271,273,275,277,279,281,283,213,284,206,303,304,311},{name = "Pullers",14,28,73,74,61,60,77,78,270,271,274,275,278,279,282,283,305,311},{name = "Graspers",71,72,73,74,75,76,77,78,272,273,274,275,280,281,282,283},{name = "Drillers",58,59,61,60,75,76,77,78,276,277,278,279,280,281,282,283},{name = "Slicers",115,269,270,271,272,273,274,275,276,277,278,279,280,281,282,283},{name = "Scissors",178,179,182,183,180,181,184,185},{name = "Unique",114,160,161,175,242,243,306,307,206},{name = "Players",max=6,239,289,290,291,297,292,288,293,294,295,298,296}}, desc = "Move on their own, usually with a certain force attached to them.", icon = 2}
lists[3] = {name = "Generators", cells = {max=4,{name = "Generators",3,23,26,27,168,167,169,170,110,111,172,171,173,174,40,113,55,147,229,166,301},{name = "Replicators",45,46,177,302},{name = "Shifters",106,107,254,255,256,257,259,258,260,261,262,263,265,264},{name = "Gates",max=5,32,33,34,194,195,35,36,37,196,197},235}, desc = "Duplicate other cells.", icon = 3}
lists[4] = {name = "Rotators", cells = {max=3,{name = "Rotators",max=6,9,10,11,66,67,68,245,246,247,150,151,152},{name = "Flippers",30,89,90},{name = "Redirectors",max=5,17,62,63,64,65},{name = "Mixed",57,70},105}, desc = "Rotate other cells.", icon = 9}
lists[5] = {name = "Forcers", cells = {max=4,{name = "Repulsors",21,50,222},{name = "Impulsors",29,248},{name = "Grapulsors",81,82,227,228},{name = "Mirrors",15,56,80},{name = "Gears",18,19,108,109},{name = "Intakers",44,155,250,251},156}, desc = "Still cells that generate force.", icon = 21}
lists[6] = {name = "Diverters", cells  = {max=4,{name = "Diverters",16,31,38,39,208,209,93,94,83,84,85,300,91,92,95,96,86,87,88,210,233,224},{name = "Forkers",48,49,97,98,99,100,101,102},{name = "Spooners",186,187,188,189,190,191,192,193},221}, desc = "Redirects incoming cells or force to a different or multiple directions.", icon = 16}
lists[7] = {name = "Destroyers", cells = {max=4,{name = "Trashes",max=4,12,225,226,205,51,141,176,300},{name = "Enemies",max=4,13,24,163,164,244,299,160},{name = "Acids",219,220},{name = "Fire",max=3,240,241,234,242,243},{name = "Intakers",44,155,250,251}}, desc = "Destroy other cells.", icon = 12}
lists[8] = {name = "Miscellaneous", cells = {max=4,20,{name="Infectious",max=3,47,126,176,123,127,128,124,129,130,125,131,132,134,135,133,149,161,211},{name="Effect Givers",25,286,287,285,43,145,308,309,112,136,137,138,139,253,310,252,232,266,105},79,{name="Transformers",237,238,267,268},{name="Time-Related",146,148,147,222},{name="Unlocking",153,154},{name="Storing",165,175,198},{name = "AI",206,211,306,307},236,{name="Coins",223,224,230}}, desc = "The ones that don't fit into another category.", icon = 20}
lists[9] = {name = "Backgrounds", cells = {max=3,{name="Placeables","placeable","placeableR","placeableY","placeableG","placeableC","placeableB","placeableP"},"rotatable"}, desc = "Backgrounds that go behind cells. Usually used for Puzzle Mode.", icon = "placeable"}
lists[10] = {name = "Cheats", cells = {max=99,199,200,201,202,203,204}, desc = "Cells that should not be used for making or breaking vaults.\nUse of these cells might cause bugs, so be careful.", icon = 199}

function hudrotation()
	return math.graphiclerp(hudrot,hudrot+((chosen.rot-hudrot+2)%4-2),hudlerp)*math.pi*.5
end

NewButton(0,0,9001,54,"menubar","menubar",nil,nil,function() end,nil,function() return not puzzle end,"bottom",nil,{1,1,1,1},{1,1,1,1},{1,1,1,1})
local lastselects = {}
NewButton(6,6,40,40,"eraser","lastselecttab","Last Selections",nil,function() openedtab = openedtab == -2 and -1 or -2; openedsubtab = -1; propertiesopen = 0 end,false,function() return not puzzle end,"bottomright", hudrotation)
for i=1,10 do
	table.insert(lastselects,NewButton(16,i*20+34,20,20,"eraser","lastselect"..i,cellinfo["eraser"].name,cellinfo["eraser"].desc,function() propertiesopen = 0; SetSelectedCell("eraser"); openedsubtab = -1 end,false,function() return not puzzle and openedtab == -2 end,"bottomright"))
end

propertynames = {}
propertiesopen = 0
function MakePropertyMenu(properties,b)
	propertynames = {}
	propertiesopen = #properties
	local x,y
	if b.halign == 1 then
		x = 800*winxm-b.x-130
		y = b.y
	else
		x = b.x-45
		y = b.y+20
	end
	buttons.propertybg.x = x
	buttons.propertybg.y = y
	buttons.propertybg.h = #properties*25+5
	for i=1,#properties do
		local b = NewButton(x+85,y+(#properties-i+1)*25-20,20,20,"add","propertyadd"..i,nil,nil,function() chosen.data[i] = math.min(chosen.data[i]+1,999) end,nil,function() return not puzzle and propertiesopen >= i end,"bottomleft")
		local b = NewButton(x+5,y+(#properties-i+1)*25-20,20,20,"subtract","propertysub"..i,nil,nil,function() chosen.data[i] = math.max(chosen.data[i]-1,0) end,nil,function() return not puzzle and propertiesopen >= i end,"bottomleft")
		propertynames[i] = properties[i]
	end
end
	
function SetSelectedCell(id,b)	--not local so it can call itself
	if type(ModStuff.whenSelected[id]) == "function" then
		return ModStuff.whenSelected[id](b)
	end
	if id == 0 then id = "eraser"
	elseif id == "mode" then
		if chosen.mode == "All" then chosen.mode = "Or"
		elseif chosen.mode == "Or" then chosen.mode = "And"
		else chosen.mode = "All" end
		b.desc = "Changes the editing mode.\nCurrent mode: "..chosen.mode
		return
	elseif id == "shape" then
		if chosen.shape == "Circle" then chosen.shape = "Square"
		else chosen.shape = "Circle" end
		b.desc = "Changes the brush shape.\nCurrent shape: "..chosen.shape
		return
	elseif id == "randrot" then
		chosen.randrot = not chosen.randrot
		b.desc = "Testing tool.\n"..(chosen.randrot and "Enabled" or "Disabled")
		return
	elseif id == "adddata1" or id == "subdata1" or id == "adddata2" or id == "subdata2" or id == "adddata3" or id == "subdata3" then ChangeData(id) return
	elseif id == 206 and b then MakePropertyMenu({"Base", "Left", "Right"},b)
	elseif id == 221 and b then MakePropertyMenu({"ID", "Target"},b)
	elseif id == 224 and b then MakePropertyMenu({"Coins"},b)
	elseif id == 299 and b then MakePropertyMenu({"ID"},b)
	end
	if id ~= chosen.id then
		buttons.lastselecttab.icon = tex[id] and id or "X"
		for i=10,2,-1 do
			lastselects[i].onclick = lastselects[i-1].onclick
			lastselects[i].icon = lastselects[i-1].icon
			lastselects[i].name = lastselects[i-1].name
			lastselects[i].desc = lastselects[i-1].desc
		end
		lastselects[1].onclick = function() propertiesopen = 0; SetSelectedCell(id,lastselects[1]) end
		lastselects[1].icon = tex[id] and id or "X"
		if cellinfo[id] then
			lastselects[1].name = cellinfo[id].name
			lastselects[1].desc = cellinfo[id].desc
		else
			lastselects[1].name = "Placeholder B"
			lastselects[1].desc = "This ID ("..id..") doesn't exist in the version of CelLua you are using."
		end
	end
	chosen.id = id == "eraser" and 0 or id
end

for i=0,#lists do 
	local list = lists[i]
	NewButton(i*50+6,6,40,40,list.icon,"list"..i,list.name,list.desc,function() openedtab = openedtab == i and -1 or i; openedsubtab = -1; propertiesopen = 0 end,false,list.name == "Cheats" and function() return not puzzle and dodebug end or function() return not puzzle end,"bottomleft", hudrotation)
	for j=1,#list.cells do
		local cell = list.cells[j]
		if type(cell) == "table" then
			NewButton(i*50+16,j*20+34,20,20,cell[1],"list"..i.."sublist"..j,cell.name,nil,function() openedsubtab = openedsubtab == j and -1 or j; propertiesopen = 0 end,false,function() return not puzzle and openedtab == i end,"bottomleft", hudrotation)
			for k=1,#cell do
				local subcell = cell[k]
				local m = cell.max or list.cells.max
				local x = (k-1)%m+1
				local y = math.floor((k-1)/m)
				cellinfo[subcell] = cellinfo[subcell] or {name="Placeholder A",desc="Cell info was not set for this id."}
				if not cellinfo[subcell].idadded then cellinfo[subcell].desc = cellinfo[subcell].desc.."\nID: "..subcell cellinfo[subcell].idadded = true end
				local b = NewButton(i*50+16+x*20,j*20+34+y*20,20,20,tex[subcell] and subcell or "X","list"..i.."sublist"..j.."cell"..subcell,cellinfo[subcell].name,cellinfo[subcell].desc,function(b) propertiesopen = 0; SetSelectedCell(subcell,b) end,false,function() return not puzzle and openedtab == i and openedsubtab == j end,"bottomleft", hudrotation)
			end
		else
			cellinfo[cell] = cellinfo[cell] or {name="Placeholder A",desc="Cell info was not set for this id."}
			if not cellinfo[cell].idadded then cellinfo[cell].desc = cellinfo[cell].desc.."\nID: "..cell cellinfo[cell].idadded = true end
			NewButton(i*50+16,j*20+34,20,20,tex[cell] and cell or "X","list"..i.."cell"..cell,cellinfo[cell].name,cellinfo[cell].desc,function(b) propertiesopen = 0; SetSelectedCell(cell,b); openedsubtab = -1 end,false,function() return not puzzle and openedtab == i end,"bottomleft", hudrotation)
		end
	end
end

NewButton(0,0,110,30,"pix","propertybg",nil,nil,function() end,nil,function() return not puzzle and propertiesopen > 0 end,"bottomleft",nil,{.25,.25,.25,1},{.25,.25,.25,1},{.25,.25,.25,1})

--miscellaneous setup

destroysound = love.audio.newSource("destroy.ogg", "static")
unlocksound = love.audio.newSource("unlock.ogg", "static")
movesound = love.audio.newSource("move.ogg", "static")
rotatesound = love.audio.newSource("rotate.ogg", "static")
infectsound = love.audio.newSource("infect.ogg", "static")
coinsound = love.audio.newSource("coin.ogg", "static")
beep = love.audio.newSource("beep.wav", "static")
music = love.audio.newSource("scattered cells.ogg", "stream")
music2 = love.audio.newSource("stepping stones.ogg", "stream")
music3 = love.audio.newSource("seen sights.ogg", "stream")
music:setLooping(true)
music2:setLooping(true)
music3:setLooping(true)
music:setVolume(.5)
music2:setVolume(.5)
music3:setVolume(.5)
destroysound:setVolume(.5)
unlocksound:setVolume(.5)
movesound:setVolume(2)
rotatesound:setVolume(.25)
infectsound:setVolume(1.5)
coinsound:setVolume(.25)
beep:setVolume(.5)
love.audio.play(music)

local particles = {}
function NewParticles(tex)
	local part = love.graphics.newParticleSystem(tex)
	part:setSizes(4,0)
	part:setSpread(math.pi*2)
	part:setSpeed(0,200)
	part:setParticleLifetime(0.5,1)
	part:setEmissionArea("uniform",10,10)
	part:setSizeVariation(1)
	part:setLinearDamping(1)
	part:setBufferSize(1000)
	table.insert(particles,part)
	return part
end
enemyparticles = NewParticles(tex.pix)
enemyparticles:setColors(1,0,0,1,.5,0,0,1)
sparkleparticles = NewParticles(tex.sparkle)
sparkleparticles:setColors(1,0,.75,1,.5,0,.25,1)
sparkleparticles:setSizes(1,0)
stallerparticles = NewParticles(tex.pix)
stallerparticles:setColors(.5,.75,.25,1,.15,.5,0,1)
love.graphics.setBackgroundColor(.125,.125,.125)
love.graphics.setLineWidth(.5)
bulkparticles = NewParticles(tex.pix)
bulkparticles:setColors(1,.75,0,1,.5,.25,0,1)
swivelparticles = NewParticles(tex.pix)
swivelparticles:setColors(.25,.5,1,1,0.1,0.1,.75,1)
coinparticles = NewParticles(tex.sparkle)
coinparticles:setColors(1,.75,.25,1,0.5,0.25,0,1)
coinparticles:setSizes(1,0)
quantumparticles = NewParticles(tex.pix)
quantumparticles:setColors(.75,0,1,1,.375,0,.5,1)
menuparticles = love.graphics.newParticleSystem(tex[2])
menuparticles:setSizes(4)
menuparticles:setSpeed(300,1200)
menuparticles:setParticleLifetime(1,2)
menuparticles:setEmissionArea("uniform",3000,3000)
menuparticles:setBufferSize(1000)
menuparticles:setColors(1,1,1,0,1,1,1,.25,1,1,1,0)

--everything else

function ConvertId(id)
	if type(ModStuff.idMaps[id]) == "number" then
		return ModStuff.idMaps[id]
	end
	if id == 23 or id == 40 or id == 113 or id == 26 or id == 27 or id == 110 or id == 111 or id == 167 or id == 168
	or id == 169 or id == 170 or id == 171 or id == 172 or id == 173 or id == 174 or id == 301 then return 3
	elseif id == 46 or id == 302 then return 45 
	elseif id == 56 or id == 80 then return 15
	elseif id == 10 or id == 11 or id == 57 or id == 70 or id == 66 or id == 67 or id == 68 or id == 245 or id == 246 or id == 247 then return 9
	elseif id == 62 or id == 63 or id == 64 or id == 65 then return 17
	elseif id == 89 or id == 90 then return 30
	elseif id == 59 or id == 60 or id == 61 or id == 75 or id == 76 or id == 77 or id == 78 or id == 276
	or id == 277 or id == 278 or id == 279 or id == 280 or id == 281 or id == 282 or id == 283 then return 58
	elseif id == 28 or id == 73 or id == 74 or id == 270 or id == 271 or id == 274 or id == 275 or id == 305 or id == 311 then return 14
	elseif id == 72 or id == 272 or id == 273 then return 71
	elseif id == 213 or id == 269 or id == 303 or id == 304 then return 2
	elseif id == 108 then return 18
	elseif id == 109 then return 19
	elseif id == 124 or id == 125 or id == 126 or id == 127 or id == 128 or id == 129 or id == 130 or id == 131 or id == 132
	or id == 133 or id == 134 or id == 135 or id == 149 or id == 211 or id == 212 or id == 234 or id == 240 or id == 241 then return 123
	elseif id == 112 or id == 145 or id == 136 or id == 137 or id == 138 or id == 139 or id == 232 or id == 252
	or id == 253 or id == 308 or id == 309 or id == 310 then return 43
	elseif id == 33 or id == 34 or id == 35 or id == 36 or id == 37 or id == 194 or id == 195 or id == 196 or id == 197
	or id == 186 or id == 187 or id == 188 or id == 189 or id == 190 or id == 191 or id == 192 or id == 193 then return 32
	elseif id == 147 or id == 148 then return 146
	elseif id == 107 or id == 254 or id == 255 or id == 256 or id == 257 or id == 258 or id == 259
	or id == 260 or id == 261 or id == 262 or id == 263 or id == 264 or id == 265 then return 106
	elseif id == 155 or id == 250 or id == 251 then return 44
	elseif id == 160 or id == 161 or id == 175 or id == 178 or id == 179 or id == 180 or id == 181 or id == 182 or id == 183
	or id == 184 or id == 185 or id == 206 or id == 242 or id == 243 then return 114
	elseif id == 200 or id == 201 or id == 202 or id == 203 or id == 204 then return 199
	elseif id == 82 or id == 227 or id == 228 then return 81
	elseif id == 238 or id == 267 or id == 268 then return 237
	elseif id == 286 or id == 287 then return 25
	elseif id == 288 or id == 289 or id == 290 or id == 291 or id == 292 or id == 293 or id == 294 or id == 295 or id == 296 or id == 297 or id == 298 then return 239
	elseif id == 307 then return 306
	else return id end
end

function CopyVars(id)
	return id == 206 or id == 221 or id == 224 or id == 299 
end

function IsEnemy(id)
	return id == 13 or id == 24 or id == 160 or id == 163 or id == 164 or id == 244 or id == 299
end

function IsBackground(id)
	if type(ModStuff.specialTypes[id]) == "string" then
		return (ModStuff.specialTypes[id] == "background")
	end
	return id == "placeable" or id == "placeableR" or id == "placeableY" or id == "placeableG" or id == "placeableC" or id == "placeableB" or id == "placeableP" or id == "rotatable"
end

function AllChunkIds(cell)
	local ids = {}
	table.insert(ids,ConvertId(cell.id))
	if cell.id ~= 0 then table.insert(ids,"all") end
	if IsEnemy(cell.id) then table.insert(ids,"enemy") end
	if cell.vars.timerepulseright or cell.vars.timerepulseleft or cell.vars.timerepulseup or cell.vars.timerepulsedown then table.insert(ids,"timerep") end
	if cell.vars.gravdir then table.insert(ids,"gravity") end
	if cell.id == 242 or cell.id == 243 then table.insert(ids,123) end
	return ids
end

function DefaultVars(id)	--Default variables.
	if id == 206 then return {0,0,0}
	elseif id == 211 then return {[3]=250,[4]=25}
	elseif id == 212 then return {[3]=250,[4]=0}
	elseif id == 221 then return {0,0}
	elseif id == 224 or id == 299 then return {0}
	else return {} end
end

function SetChunk(x,y,cell)
	local ids = AllChunkIds(cell)
	for i=1,#ids do
		chunks[math.floor(y*.04)][math.floor(x*.04)][ids[i]] = true
		chunks.all[ids[i]] = true
	end
end

function SetChunkId(x,y,id)
	chunks[math.floor(y*.04)][math.floor(x*.04)][id] = true
	chunks.all[id] = true
end

function GetChunk(x,y,id)
	return chunks[math.floor(y*.04)][math.floor(x*.04)][id]
end

function ResetPortals()
	portals = {}
	reverseportals = {}
	for x=1,width-2 do
		for y=1,height-2 do
			local cell = cells[y][x]
			if cell.id == 221 then
				portals[cell.vars[1]] = portals[cell.vars[1]] or {}
				reverseportals[cell.vars[2]] = reverseportals[cell.vars[2]] or {}
				table.insert(portals[cell.vars[1]],{x,y})
				table.insert(reverseportals[cell.vars[2]],{x,y})
			end
		end
	end
end

function PlaceCell(x,y,cell)
	if not cell.vars then
		if cell.id == 206 then cell.vars = {math.min(chosen.data[1],4),math.min(chosen.data[2],4),math.min(chosen.data[3],4)}
		elseif cell.id == 221 then cell.vars = {chosen.data[1],chosen.data[2]}
		elseif cell.id == 224 or cell.id == 299 then cell.vars = {chosen.data[1]}
		else cell.vars = DefaultVars(cell.id) end
	end
	if x > 0 and x < width-1 and y > 0 and y < height-1 then
		local was = cells[y][x]
		cells[y][x] = cell
		if cells[y][x].id == 221 or was.id == 221 then
			ResetPortals()
		end
		if isinitial then
			initial[y][x].id = cells[y][x].id
			initial[y][x].rot = cells[y][x].rot
			initial[y][x].vars = table.copy(cells[y][x].vars)
			initial[y][x].lastvars = {x,y,initial[y][x].rot}
			cells[y][x] = table.copy(initial[y][x])
		end
		if type(ModStuff.onPlace[cell.id]) == "function" then
			ModStuff.onPlace[cell.id](cell, x, y, was)
		end
		SetChunk(x,y,cell)
		return true
	end
end

function SetCell(x,y,cell)
	if cells[0][0].id == "wrap" then if x <= 0 then x = x + width - 2 elseif x >= width - 1 then x = x - width + 2 end if y <= 0 then y = y + height - 2 elseif y >= height - 1 then y = y - height + 2 end end
	if x > 0 and x < width-1 and y > 0 and y < height-1 then
		local was = cells[y][x].id
		cells[y][x] = cell
		if cells[y][x].id == 221 or was == 221 then
			ResetPortals()
		end
		if type(ModStuff.onSetCell[cell.id]) == "function" then
			ModStuff.onSetCell[cell.id](cell, x, y, was)
		end
		SetChunk(x,y,cell)
	end
end

function GetCell(x,y)
	if cells[0][0].id == "wrap" then if x <= 0 then x = x + width - 2 elseif x >= width - 1 then x = x - width + 2 end if y <= 0 then y = y + height - 2 elseif y >= height - 1 then y = y - height + 2 end end
	return (x >= 0 and x < width and y >= 0 and y < height) and cells[y][x] or {id=0,rot=0,lastvars={0,0,0},vars={}}
end

function GetData(x,y)
	if cells[0][0].id == "wrap" then if x <= 0 then x = x + width - 2 elseif x >= width - 1 then x = x - width + 2 end if y <= 0 then y = y + height - 2 elseif y >= height - 1 then y = y - height + 2 end end
	return (x >= 0 and x < width and y >= 0 and y < height) and stilldata[y][x] or {}
end

function GetPlaceable(x,y)
	return (x >= 0 and x < width and y >= 0 and y < height) and placeables[y][x]
end

function SetPlaceable(x,y,v)
	if (x >= 0 and x < width and y >= 0 and y < height) then
		placeables[y][x] = v
	end
end

function CopyCell(x,y)
	return table.copy(GetCell(x,y))
end

function ClearWorld()
	bgsprites:clear()
	TogglePause(true)
	selection.on = false
	isinitial = true
	mainmenu = false
	winscreen = false
	cells = {}
	stilldata = {}
	initial = {}
	placeables = {}
	chunks = {}
	width = newwidth+2
	height = newheight+2
	for y=0,height*.04-.04 do
		chunks[y] = {}
		for x=0,width*.04-.04 do
			chunks[y][x] = {}
		end
	end
	chunks.all = {}
	for y=0,height-1 do
		cells[y] = {}
		stilldata[y] = {}
		initial[y] = {}
		placeables[y] = {}
		for x=0,width-1 do
			if x == 0 or x == width-1 or y == 0 or y == height-1 then
				cells[y][x] = {id=bordercells[border],rot=0,lastvars={x,y,0},vars={}}
				stilldata[y][x] = {}
				initial[y][x] = {id=bordercells[border],rot=0,lastvars={x,y,0},vars={}}
			else
				cells[y][x] = getempty()
				stilldata[y][x] = {}
				initial[y][x] = getempty()
			end
			if x > 0 and x < width-1 and y > 0 and y < height-1 then
				bgsprites:add((x-1)*20,(y-1)*20)
			end
		end
	end
	subtick = 0
	ResetPortals()
end

function RefreshWorld()
	bgsprites:clear()
	TogglePause(true)
	selection.on = false
	isinitial = true
	mainmenu = false
	winscreen = false
	cells = {}
	stilldata = {}
	chunks = {}
	for y=0,newheight*.04+.04 do
		chunks[y] = {}
		for x=0,newwidth*.04+.04 do
			chunks[y][x] = {}
		end
	end
	chunks.all = {}
	for y=0,math.max(height-1,newheight+1) do
		if y >= height then
			cells[y] = {}
			stilldata[y] = {}
			initial[y] = {}
			placeables[y] = {}
		end
		if y > newheight+1 then
			initial[y] = nil
			placeables[y] = nil
		else
			cells[y] = {}
			stilldata[y] = {}
			for x=0,math.max(width-1,newwidth+1) do
				if x == 0 or x == newwidth+1 or (y == 0 or y == newheight+1) and x <= newwidth+1 then
					cells[y][x] = {id=bordercells[border],rot=0,lastvars={x,y,0},vars={}}
					stilldata[y][x] = {}
					initial[y][x] = {id=bordercells[border],rot=0,lastvars={x,y,0},vars={}}
					if x > 0 and x < newwidth+1 and y > 0 and y < newheight+1 then
						bgsprites:add((x-1)*20,(y-1)*20)
					end
				elseif x > newwidth+1 then
					initial[y][x] = nil
					placeables[y][x] = nil
				elseif x >= width-1 or y >= height-1 then
					cells[y][x] = getempty()
					stilldata[y][x] = {}
					initial[y][x] = getempty()
					if x > 0 and x < newwidth+1 and y > 0 and y < newheight+1 then
						bgsprites:add((x-1)*20,(y-1)*20)
					end
				else
					cells[y][x] = table.copy(initial[y][x])
					stilldata[y][x] = {}
					if x > 0 and x < newwidth+1 and y > 0 and y < newheight+1 then
						bgsprites:add((x-1)*20,(y-1)*20)
					end
					SetChunk(x,y,initial[y][x])
				end
			end
		end
	end
	width = newwidth+2
	height = newheight+2
	subtick = 0
	ResetPortals()
end

local b74cheatsheet = {}	--i dont know why, but for some reason i have to seperate the cheatsheets even though they use the exact same characters
for i=0,9 do b74cheatsheet[tostring(i)] = i end
for i=0,25 do b74cheatsheet[string.char(string.byte("a")+i)] = i+10 end
for i=0,25 do b74cheatsheet[string.char(string.byte("A")+i)] = i+36 end
b74cheatsheet["!"] = 62 b74cheatsheet["$"] = 63 b74cheatsheet["%"] = 64 b74cheatsheet["&"] = 65 b74cheatsheet["+"] = 66
b74cheatsheet["-"] = 67 b74cheatsheet["."] = 68 b74cheatsheet["="] = 69 b74cheatsheet["?"] = 70 b74cheatsheet["^"] = 71
b74cheatsheet["{"] = 72 b74cheatsheet["}"] = 73
local cheatsheet = {}
for i=0,9 do cheatsheet[tostring(i)] = i end
for i=0,25 do cheatsheet[string.char(string.byte("a")+i)] = i+10 end
for i=0,25 do cheatsheet[string.char(string.byte("A")+i)] = i+36 end
cheatsheet["!"] = 62 cheatsheet["$"] = 63 cheatsheet["%"] = 64 cheatsheet["&"] = 65 cheatsheet["+"] = 66
cheatsheet["-"] = 67 cheatsheet["."] = 68 cheatsheet["="] = 69 cheatsheet["?"] = 70 cheatsheet["^"] = 71
cheatsheet["{"] = 72 cheatsheet["}"] = 73 cheatsheet["/"] = 74 cheatsheet["#"] = 75 cheatsheet["_"] = 76
cheatsheet["*"] = 77 cheatsheet["'"] = 78 cheatsheet[":"] = 79 cheatsheet[","] = 80 cheatsheet["@"] = 81
cheatsheet["~"] = 82 cheatsheet["|"] = 83 
for k,v in pairs(cheatsheet) do
	cheatsheet[v] = k				--basically "invert" table
end

function unbase74(origvalue)
	local result = 0
	local iter = 0
	local chars = string.len(origvalue)
	for i=chars,1,-1 do
		iter = iter + 1
		local mult = 74^(iter-1)
		result = result + b74cheatsheet[string.sub(origvalue,i,i)] * mult
	end
	return result
end

function unbase84(origvalue)
	local neg = false
	if string.sub(origvalue,1,1) == ">" then
		neg = true
		origvalue = string.sub(origvalue,2,#origvalue)
	end
	local result = 0
	local iter = 0
	local chars = string.len(origvalue)
	for i=chars,1,-1 do
		iter = iter + 1
		local mult = 84^(iter-1)
		result = result + cheatsheet[string.sub(origvalue,i,i)] * mult
	end
	return result*(neg and -1 or 1)
end

function base84(origvalue)
	local result = ""
	local iter = 0
	local neg = false
	if origvalue == 0 then return 0
	elseif origvalue < 0 then origvalue = -origvalue; neg = true end
	while true do
		iter = iter + 1
		local lowermult = 84^(iter-1)
		local mult = 84^(iter)
		if lowermult > origvalue then
			break
		else
			result = cheatsheet[math.floor(origvalue/lowermult)%84] .. result
		end
	end
	if neg then result = ">"..result end
	return result
end

local V3Cells = {}
V3Cells["0"] = {3,0,false} V3Cells["i"] = {3,1,false} V3Cells["A"] = {3,2,false} V3Cells["S"] = {3,3,false}
V3Cells["1"] = {3,0,true} V3Cells["j"] = {3,1,true} V3Cells["B"] = {3,2,true} V3Cells["T"] = {3,3,true} 
V3Cells["2"] = {9,0,false} V3Cells["k"] = {9,1,false} V3Cells["C"] = {9,2,false} V3Cells["U"] = {9,3,false}
V3Cells["3"] = {9,0,true} V3Cells["l"] = {9,1,true} V3Cells["D"] = {9,2,true} V3Cells["V"] = {9,3,true} 
V3Cells["4"] = {10,0,false} V3Cells["m"] = {10,1,false} V3Cells["E"] = {10,2,false} V3Cells["W"] = {10,3,false}
V3Cells["5"] = {10,0,true} V3Cells["n"] = {10,1,true} V3Cells["F"] = {10,2,true} V3Cells["X"] = {10,3,true} 
V3Cells["6"] = {2,0,false} V3Cells["o"] = {2,1,false} V3Cells["G"] = {2,2,false} V3Cells["Y"] = {2,3,false}
V3Cells["7"] = {2,0,true} V3Cells["p"] = {2,1,true} V3Cells["H"] = {2,2,true} V3Cells["Z"] = {2,3,true} 
V3Cells["8"] = {5,0,false} V3Cells["q"] = {5,1,false} V3Cells["I"] = {5,2,false} V3Cells["!"] = {5,3,false}
V3Cells["9"] = {5,0,true} V3Cells["r"] = {5,1,true} V3Cells["J"] = {5,2,true} V3Cells["$"] = {5,3,true} 
V3Cells["a"] = {4,0,false} V3Cells["s"] = {4,1,false} V3Cells["K"] = {4,2,false} V3Cells["%"] = {4,3,false}
V3Cells["b"] = {4,0,true} V3Cells["t"] = {4,1,true} V3Cells["L"] = {4,2,true} V3Cells["&"] = {4,3,true} 
V3Cells["c"] = {1,0,false} V3Cells["u"] = {1,1,false} V3Cells["M"] = {1,2,false} V3Cells["+"] = {1,3,false}
V3Cells["d"] = {1,0,true} V3Cells["v"] = {1,1,true} V3Cells["N"] = {1,2,true} V3Cells["-"] = {1,3,true} 
V3Cells["e"] = {13,0,false} V3Cells["w"] = {13,1,false} V3Cells["O"] = {13,2,false} V3Cells["."] = {13,3,false}
V3Cells["f"] = {13,0,true} V3Cells["x"] = {13,1,true} V3Cells["P"] = {13,2,true} V3Cells["="] = {13,3,true} 
V3Cells["g"] = {12,0,false} V3Cells["y"] = {12,1,false} V3Cells["Q"] = {12,2,false} V3Cells["?"] = {12,3,false}
V3Cells["h"] = {12,0,true} V3Cells["z"] = {12,1,true} V3Cells["R"] = {12,2,true} V3Cells["^"] = {12,3,true} 
V3Cells["{"] = {0,0,false} V3Cells["}"] = {0,0,true} V3Cells[":"] = {0,0,false}

function NumToCell(num,hasplaceables)
	if hasplaceables then
		local id = (math.floor(num/8))
		if id == 0 then id = 1 elseif id == 1 then id = 0 end
		return id, math.floor(num*.5)%4, num%2==1		--id, rot, placeable
	else
		local id = (math.floor(num/4))
		if id == 0 then id = 1 elseif id == 1 then id = 0 end
		return id, num%4
	end
end

function ToOldId(id)
	return id == 1 and -1 or id ~= 0 and id - 1 or 0
end

function EncodeCell(x,y)
	local cell
	if type(x) == "number" then
		cell = initial[y][x]
	else
		cell = x
	end
	local code = ""
	local id = cell.id
	local rot = cell.rot
	if id == 0 or id == 1 or id == 4 or id == 9 or id == 10 or id == 11 or id == 12 or id == 13 or id == 18 or id == 19 or id == 20 or id == 21 or id == 22 or id == 24
	or id == 25 or id == 29 or id == 39 or id == 41 or id == 43 or id == 47 or id == 50 or id == 51 or id == 56 or id == 62 or id == 63 or id == 64 or id == 65 or id == 79
	or id == 80 or id == 81 or id == 82 or id == 104 or id == 105 or id == 108 or id == 109 or id == 112 or id == 116 or id == 117 or id == 118 or id == 119 or id == 120 or id == 121
	or id == 122 or id == 123 or id == 124 or id == 125 or id == 126 or id == 127 or id == 128 or id == 129 or id == 130 or id == 131 or id == 132 or id == 133 or id == 133 or id == 134
	or id == 135 or id == 136 or id == 137 or id == 138 or id == 139 or id == 141 or id == 142 or id == 144 or id == 145 or id == 149 or id == 150 or id == 151 or id == 152 or id == 153 or id == 154
	or id == 162 or id == 163 or id == 165 or id == 176 or id == 203 or id == 204 or id == 205 or id == 211 or id == 214 or id == 219 or id == 220 or id == 222 or id == 223 or id == 224 or id == 231
	or id == 235 or id == 239 or id == 240 or id == 241 or id == 245 or id == 246 or id == 247 or id == 248 or id == 251 or id == 252 or id == 266 or id == 253 or id == 285 or id == 286 or id == 288
	or id == 289 or id == 290 or id == 291 or id == 292 or id == 293 or id == 294 or id == 295 or id == 296 or id == 297 or id == 298 or id == 308 or id == 309 or id == 310 then
		rot = 0
	elseif id == 5 or id == 15 or id == 30 or id == 31 or id == 38 or id == 66 or id == 67 or id == 68 or id == 69 or id == 70 or id == 84 or id == 85 or id == 87 or id == 88 or id == 89 or id == 90
	or id == 92 or id == 202 or id == 207 or id == 210 or id == 215 or id == 225 or id == 226 or id == 233 or id == 249 or id == 250 or id == 287 then
		rot = rot%2
	end
	if type(id) == "number" then
		code = base84(id*4+rot)
		if string.len(code) > 1 then
			if string.len(code) > 2 then
				code = ")"..#code..code
			else
				code = "("..code
			end
		end
	elseif type(id) == "string" then
		code = "<"..id.."<"..rot
	end
	if cell.vars then
		for k,v in pairs(cell.vars) do
			code = code.."["
			if type(k) == "number" then
				local str = base84(k)
				if string.len(str) >= 3 then
					code = code..")"..#str..str
				elseif string.len(str) >= 2 then
					code = code.."("..str
				else
					code = code..""..str
				end
			elseif type(k) == "string" then	
				code = code.."<"..k.."<"
			end
			if type(v) == "number" then
				local str = base84(v)
				if string.len(str) >= 3 then
					code = code..")"..#str..str
				elseif string.len(str) >= 2 then
					code = code.."("..str
				else
					code = code..""..str
				end
			elseif type(v) == "string" then	
				code = code.."<"..v.."<"
			end
		end
	end
	if type(x) == "number" then
		local p = GetPlaceable(x,y)
		if p then
			if type(p) == "number" then
				local str = base84(p)
				if string.len(str) >= 3 then
					code = ")"..#str..str..code
				elseif string.len(str) >= 2 then
					code = "("..str..code
				else
					code = ""..str..code
				end
			elseif type(p) == "string" then	
				code = "<"..p.."<"..code
			end
			code = "]"..code
		end
	end
	return code
end

function DecodeV3(code)
	local currentspot = 0
	local currentcharacter = 3 --start right after V3;
	local storedstring = ""
	TogglePause(true)
	isinitial = true
	undocells = {}
	subticking = false
	title,subtitle = "","" 
	selection.on = false
	while true do
		currentcharacter = currentcharacter + 1
		if string.sub(code,currentcharacter,currentcharacter) == ";" then
			break
		else
			storedstring = storedstring..string.sub(code,currentcharacter,currentcharacter)
		end
	end
	width = unbase74(storedstring)+2
	storedstring = ""
	while true do
		currentcharacter = currentcharacter + 1
		if string.sub(code,currentcharacter,currentcharacter) == ";" then
			break
		else
			storedstring = storedstring..string.sub(code,currentcharacter,currentcharacter) 
		end
	end
	height = unbase74(storedstring)+2
	newwidth = width-2
	newheight = height-2
	border = 2
	ClearWorld()
	storedstring = ""
	while true do
		currentcharacter = currentcharacter + 1
		if string.sub(code,currentcharacter,currentcharacter) == ")" then							--basic repeat
			local howmany = unbase74(string.sub(code,currentcharacter+1,currentcharacter+1))
			local howmuch = unbase74(string.sub(code,currentcharacter+2,currentcharacter+2))
			local curcell = 0
			local startspot = currentspot
			for i=1,howmuch do
				if curcell == 0 then
					curcell = howmany
				else
					curcell = curcell - 1
				end
				currentspot = currentspot + 1
				local x,y = (currentspot-1)%(width-2)+1,math.floor(height-1-(currentspot)/(width-2))
				PlaceCell(x,y,CopyCell((startspot-curcell-1)%(width-2)+1,math.floor(height-1-(startspot-curcell)/(width-2))))
				SetPlaceable(x,y,GetPlaceable((startspot-curcell-1)%(width-2)+1,math.floor(height-1-(startspot-curcell)/(width-2))))
			end
			currentcharacter = currentcharacter + 2
		elseif string.sub(code,currentcharacter,currentcharacter) == "(" then						--advanced repeat
			local howmany = ""
			local howmuch = ""
			local simplemuch = false
			while true do
				currentcharacter = currentcharacter + 1
				if string.sub(code,currentcharacter,currentcharacter) == "(" then
					break
				elseif string.sub(code,currentcharacter,currentcharacter) == ")" then
					simplemuch = true
					break
				else
					howmany = howmany..string.sub(code,currentcharacter,currentcharacter)
				end
			end
			howmany = unbase74(howmany)
			if simplemuch then
				currentcharacter = currentcharacter + 1
				howmuch = unbase74(string.sub(code,currentcharacter,currentcharacter))
			else
				while true do
					currentcharacter = currentcharacter + 1
					if string.sub(code,currentcharacter,currentcharacter) == ")" then
						break
					else
						howmuch = howmuch..string.sub(code,currentcharacter,currentcharacter)
					end
				end
				howmuch = unbase74(howmuch)
			end
			local curcell = 0
			local startspot = currentspot
			for i=1,howmuch do
				if curcell == 0 then
					curcell = howmany
				else
					curcell = curcell - 1
				end
				currentspot = currentspot + 1
				local x,y = (currentspot-1)%(width-2)+1,math.floor(height-1-(currentspot)/(width-2))
				PlaceCell(x,y,CopyCell((startspot-curcell-1)%(width-2)+1,math.floor(height-1-(startspot-curcell)/(width-2))))
				SetPlaceable(x,y,GetPlaceable((startspot-curcell-1)%(width-2)+1,math.floor(height-1-(startspot-curcell)/(width-2))))
			end
		elseif string.sub(code,currentcharacter,currentcharacter) == ";" then
			break
		else																						--one cell
			currentspot = currentspot + 1
			local cell = V3Cells[string.sub(code,currentcharacter,currentcharacter)]
			local x,y = (currentspot-1)%(width-2)+1,math.floor(height-1-(currentspot)/(width-2))
			PlaceCell(x,y,{id=cell[1],rot=cell[2],lastvars={x,y,0},vars=DefaultVars(cell[1])})
			if cell[3] then
				SetPlaceable(x,y,"placeable")
			end
		end
	end
	bgsprites:clear()
	for y=0,height-1 do
		for x=0,width-1 do
			bgsprites:add((x-1)*20,(y-1)*20)
		end
	end
end

function DecodeK1(code)
	local currentspot = 0
	local currentcharacter = 3 --start right after K1;
	local storedstring = ""
	TogglePause(true)
	isinitial = true
	undocells = {}
	subticking = false
	title,subtitle = "","" 
	selection.on = false
	while true do
		currentcharacter = currentcharacter + 1
		if string.sub(code,currentcharacter,currentcharacter) == ";" then
			break
		else
			storedstring = storedstring..string.sub(code,currentcharacter,currentcharacter) 
		end
	end
	width = unbase84(storedstring)+2
	storedstring = ""
	while true do
		currentcharacter = currentcharacter + 1
		if string.sub(code,currentcharacter,currentcharacter) == ";" then
			break
		else
			storedstring = storedstring..string.sub(code,currentcharacter,currentcharacter) 
		end
	end
	height = unbase84(storedstring)+2
	local hasplaceables
	if string.sub(code,currentcharacter+1,currentcharacter+1) == "0" then
		hasplaceables = false
	else
		hasplaceables = true
	end
	newwidth = width-2
	newheight = height-2
	border = 1
	currentcharacter = currentcharacter + 2
	ClearWorld()
	while currentspot <= (width-2)*(height-2) do
		currentcharacter = currentcharacter + 1
		if string.sub(code,currentcharacter,currentcharacter) == "<" then						--duplicate the last 6 cells X times
			local howmuch = 0
			currentcharacter = currentcharacter + 1
			if string.sub(code,currentcharacter,currentcharacter) == "(" then
				howmuch = unbase84(string.sub(code,currentcharacter+1,currentcharacter+2))*6
				currentcharacter = currentcharacter + 2
			else
				howmuch = unbase84(string.sub(code,currentcharacter,currentcharacter))*6
			end
			local startspot = currentspot
			local curcell = 1
			for i=1,howmuch do
				if curcell == 1 then
					curcell = 6
				else
					curcell = curcell - 1
				end
				currentspot = currentspot + 1
				local x,y = (currentspot-1)%(width-2)+1,math.floor((currentspot-1)/(width-2)+1)
				PlaceCell(x,y,CopyCell((startspot-curcell)%(width-2)+1,math.floor((startspot-curcell)/(width-2)+1)))
			end
		elseif string.sub(code,currentcharacter,currentcharacter) == ">" then						--duplicate the last 5 cells X times
			local howmuch = 0
			currentcharacter = currentcharacter + 1
			if string.sub(code,currentcharacter,currentcharacter) == "(" then
				howmuch = unbase84(string.sub(code,currentcharacter+1,currentcharacter+2))*5
				currentcharacter = currentcharacter + 2
			else
				howmuch = unbase84(string.sub(code,currentcharacter,currentcharacter))*5
			end
			local startspot = currentspot
			local curcell = 1
			for i=1,howmuch do
				if curcell == 1 then
					curcell = 5
				else
					curcell = curcell - 1
				end
				currentspot = currentspot + 1
				local x,y = (currentspot-1)%(width-2)+1,math.floor((currentspot-1)/(width-2)+1)
				PlaceCell(x,y,CopyCell((startspot-curcell)%(width-2)+1,math.floor((startspot-curcell)/(width-2)+1)))
			end
		elseif string.sub(code,currentcharacter,currentcharacter) == "[" then						--duplicate the last 4 cells X times
			local howmuch = 0
			currentcharacter = currentcharacter + 1
			if string.sub(code,currentcharacter,currentcharacter) == "(" then
				howmuch = unbase84(string.sub(code,currentcharacter+1,currentcharacter+2))*4
				currentcharacter = currentcharacter + 2
			else
				howmuch = unbase84(string.sub(code,currentcharacter,currentcharacter))*4
			end
			local startspot = currentspot
			local curcell = 1
			for i=1,howmuch do
				if curcell == 1 then
					curcell = 4
				else
					curcell = curcell - 1
				end
				currentspot = currentspot + 1
				local x,y = (currentspot-1)%(width-2)+1,math.floor((currentspot-1)/(width-2)+1)
				PlaceCell(x,y,CopyCell((startspot-curcell)%(width-2)+1,math.floor((startspot-curcell)/(width-2)+1)))
			end
		elseif string.sub(code,currentcharacter,currentcharacter) == "]" then						--duplicate the last 3 cells X times
			local howmuch = 0
			currentcharacter = currentcharacter + 1
			if string.sub(code,currentcharacter,currentcharacter) == "(" then
				howmuch = unbase84(string.sub(code,currentcharacter+1,currentcharacter+2))*3
				currentcharacter = currentcharacter + 2
			else
				howmuch = unbase84(string.sub(code,currentcharacter,currentcharacter))*3
			end
			local startspot = currentspot
			local curcell = 1
			for i=1,howmuch do
				if curcell == 1 then
					curcell = 3
				else
					curcell = curcell - 1
				end
				currentspot = currentspot + 1
				local x,y = (currentspot-1)%(width-2)+1,math.floor((currentspot-1)/(width-2)+1)
				PlaceCell(x,y,CopyCell((startspot-curcell)%(width-2)+1,math.floor((startspot-curcell)/(width-2)+1)))
			end
		elseif string.sub(code,currentcharacter,currentcharacter) == ")" then						--duplicate the last 2 cells X times
			local howmuch = 0
			currentcharacter = currentcharacter + 1
			if string.sub(code,currentcharacter,currentcharacter) == "(" then
				howmuch = unbase84(string.sub(code,currentcharacter+1,currentcharacter+2))*2
				currentcharacter = currentcharacter + 2
			else
				howmuch = unbase84(string.sub(code,currentcharacter,currentcharacter))*2
			end
			local startspot = currentspot
			local curcell = 1
			for i=1,howmuch do
				if curcell == 1 then
					curcell = 2
				else
					curcell = curcell - 1
				end
				currentspot = currentspot + 1
				local x,y = (currentspot-1)%(width-2)+1,math.floor((currentspot-1)/(width-2)+1)
				PlaceCell(x,y,CopyCell((startspot-curcell)%(width-2)+1,math.floor((startspot-curcell)/(width-2)+1)))
			end
		elseif string.sub(code,currentcharacter,currentcharacter) == ";" then
			break
		else																						--one cell
			local celltype,cellrot,place
			if string.sub(code,currentcharacter,currentcharacter) == "(" then
				celltype,cellrot,place = NumToCell(unbase84(string.sub(code,currentcharacter+1,currentcharacter+2)),hasplaceables)
				currentcharacter = currentcharacter + 2
			else
				celltype,cellrot,place = NumToCell(unbase84(string.sub(code,currentcharacter,currentcharacter)),hasplaceables)
			end
			currentspot = currentspot + 1
			local x,y = (currentspot-1)%(width-2)+1,math.floor((currentspot-1)/(width-2)+1)
			PlaceCell(x,y,{id=celltype,rot=cellrot,lastvars={x,y,0},vars=DefaultVars(celltype)})
			if place then
				SetPlaceable(x,y,"placeable")
			end
		end  
	end
	bgsprites:clear()
	for y=0,height-1 do
		for x=0,width-1 do
			bgsprites:add((x-1)*20,(y-1)*20)
		end
	end
end

function DecodeK2(code)
	local currentspot = 0
	local currentcharacter = 3 --start right after K2;
	local storedstring = ""
	TogglePause(true)
	isinitial = true
	undocells = {}
	subticking = false
	title,subtitle = "","" 
	selection.on = false
	while true do
		currentcharacter = currentcharacter + 1
		if string.sub(code,currentcharacter,currentcharacter) == ";" then
			break
		else
			storedstring = storedstring..string.sub(code,currentcharacter,currentcharacter) 
		end
	end
	width = unbase84(storedstring)+2
	storedstring = ""
	while true do
		currentcharacter = currentcharacter + 1
		if string.sub(code,currentcharacter,currentcharacter) == ";" then
			break
		else
			storedstring = storedstring..string.sub(code,currentcharacter,currentcharacter) 
		end
	end
	height = unbase84(storedstring)+2
	local hasplaceables
	if unbase84(string.sub(code,currentcharacter+1,currentcharacter+1))%2 == 0 then
		hasplaceables = false
	else
		hasplaceables = true
	end
	newwidth = width-2
	newheight = height-2
	border = math.floor(unbase84(string.sub(code,currentcharacter+1,currentcharacter+1))*.5)+1
	currentcharacter = currentcharacter + 2
	ClearWorld()
	while currentspot <= (width-2)*(height-2) do
		currentcharacter = currentcharacter + 1
		if string.sub(code,currentcharacter,currentcharacter) == "<" then							--duplicate arbitrary amount of cells
			local howmany = 0
			local howmuch = 0
			currentcharacter = currentcharacter + 1
			if string.sub(code,currentcharacter,currentcharacter) == "(" then
				howmany = unbase84(string.sub(code,currentcharacter+1,currentcharacter+2))
				currentcharacter = currentcharacter + 2
			else
				howmany = unbase84(string.sub(code,currentcharacter,currentcharacter))
			end
			currentcharacter = currentcharacter + 1
			if string.sub(code,currentcharacter,currentcharacter) == "(" then
				howmuch = unbase84(string.sub(code,currentcharacter+1,currentcharacter+2))*howmany
				currentcharacter = currentcharacter + 2
			else
				howmuch = unbase84(string.sub(code,currentcharacter,currentcharacter))*howmany
			end
			local startspot = currentspot
			local curcell = 1
			for i=1,howmuch do
				if curcell == 1 then
					curcell = howmany
				else
					curcell = curcell - 1
				end
				currentspot = currentspot + 1
				local x,y = (currentspot-1)%(width-2)+1,math.floor((currentspot-1)/(width-2)+1)
				PlaceCell(x,y,CopyCell((startspot-curcell)%(width-2)+1,math.floor((startspot-curcell)/(width-2)+1)))
			end
		elseif string.sub(code,currentcharacter,currentcharacter) == ">" then						--duplicate the last 5 cells X times
			local howmuch = 0
			currentcharacter = currentcharacter + 1
			if string.sub(code,currentcharacter,currentcharacter) == "(" then
				howmuch = unbase84(string.sub(code,currentcharacter+1,currentcharacter+2))*5
				currentcharacter = currentcharacter + 2
			else
				howmuch = unbase84(string.sub(code,currentcharacter,currentcharacter))*5
			end
			local startspot = currentspot
			local curcell = 1
			for i=1,howmuch do
				if curcell == 1 then
					curcell = 5
				else
					curcell = curcell - 1
				end
				currentspot = currentspot + 1
				local x,y = (currentspot-1)%(width-2)+1,math.floor((currentspot-1)/(width-2)+1)
				PlaceCell(x,y,CopyCell((startspot-curcell)%(width-2)+1,math.floor((startspot-curcell)/(width-2)+1)))
			end
		elseif string.sub(code,currentcharacter,currentcharacter) == "[" then						--duplicate the last 4 cells X times
			local howmuch = 0
			currentcharacter = currentcharacter + 1
			if string.sub(code,currentcharacter,currentcharacter) == "(" then
				howmuch = unbase84(string.sub(code,currentcharacter+1,currentcharacter+2))*4
				currentcharacter = currentcharacter + 2
			else
				howmuch = unbase84(string.sub(code,currentcharacter,currentcharacter))*4
			end
			local startspot = currentspot
			local curcell = 1
			for i=1,howmuch do
				if curcell == 1 then
					curcell = 4
				else
					curcell = curcell - 1
				end
				currentspot = currentspot + 1
				local x,y = (currentspot-1)%(width-2)+1,math.floor((currentspot-1)/(width-2)+1)
				PlaceCell(x,y,CopyCell((startspot-curcell)%(width-2)+1,math.floor((startspot-curcell)/(width-2)+1)))
			end
		elseif string.sub(code,currentcharacter,currentcharacter) == "]" then						--duplicate the last 3 cells X times
			local howmuch = 0
			currentcharacter = currentcharacter + 1
			if string.sub(code,currentcharacter,currentcharacter) == "(" then
				howmuch = unbase84(string.sub(code,currentcharacter+1,currentcharacter+2))*3
				currentcharacter = currentcharacter + 2
			else
				howmuch = unbase84(string.sub(code,currentcharacter,currentcharacter))*3
			end
			local startspot = currentspot
			local curcell = 1
			for i=1,howmuch do
				if curcell == 1 then
					curcell = 3
				else
					curcell = curcell - 1
				end
				currentspot = currentspot + 1
				local x,y = (currentspot-1)%(width-2)+1,math.floor((currentspot-1)/(width-2)+1)
				PlaceCell(x,y,CopyCell((startspot-curcell)%(width-2)+1,math.floor((startspot-curcell)/(width-2)+1)))
			end
		elseif string.sub(code,currentcharacter,currentcharacter) == ")" then						--duplicate the last 2 cells X times
			local howmuch = 0
			currentcharacter = currentcharacter + 1
			if string.sub(code,currentcharacter,currentcharacter) == "(" then
				howmuch = unbase84(string.sub(code,currentcharacter+1,currentcharacter+2))*2
				currentcharacter = currentcharacter + 2
			else
				howmuch = unbase84(string.sub(code,currentcharacter,currentcharacter))*2
			end
			local startspot = currentspot
			local curcell = 1
			for i=1,howmuch do
				if curcell == 1 then
					curcell = 2
				else
					curcell = curcell - 1
				end
				currentspot = currentspot + 1
				local x,y = (currentspot-1)%(width-2)+1,math.floor((currentspot-1)/(width-2)+1)
				PlaceCell(x,y,CopyCell((startspot-curcell)%(width-2)+1,math.floor((startspot-curcell)/(width-2)+1)))
			end
		elseif string.sub(code,currentcharacter,currentcharacter) == ";" then
			break
		else																						--one cell
			local celltype,cellrot,place
			if string.sub(code,currentcharacter,currentcharacter) == "(" then
				celltype,cellrot,place = NumToCell(unbase84(string.sub(code,currentcharacter+1,currentcharacter+2)),hasplaceables)
				currentcharacter = currentcharacter + 2
			else
				celltype,cellrot,place = NumToCell(unbase84(string.sub(code,currentcharacter,currentcharacter)),hasplaceables)
			end
			currentspot = currentspot + 1
			local x,y = (currentspot-1)%(width-2)+1,math.floor((currentspot-1)/(width-2)+1)
			PlaceCell(x,y,{id=celltype,rot=cellrot,lastvars={x,y,0},vars=DefaultVars(celltype)})
			if place then
				SetPlaceable(x,y,"placeable")
			end
		end  
	end
	bgsprites:clear()
	for y=0,height-1 do
		for x=0,width-1 do
			bgsprites:add((x-1)*20,(y-1)*20)
		end
	end
end

function DecodeK3(code)
	local currentspot = 0
	local currentcharacter = 3 --start right after K3
	local storedstring = ""
	TogglePause(true)
	isinitial = true
	undocells = {}
	subticking = false
	title,subtitle = "","" 
	selection.on = false
	if string.sub(code,currentcharacter,currentcharacter) == ":" then
		while true do
			currentcharacter = currentcharacter + 1
			local character = string.sub(code,currentcharacter,currentcharacter)
			if character == ";" or character == ":" then
				break
			else
				title = title..character
			end
		end
		if string.sub(code,currentcharacter,currentcharacter) == ":" then
			while true do
				currentcharacter = currentcharacter + 1
				local character = string.sub(code,currentcharacter,currentcharacter)
				if character == ";" then
					break
				else
					subtitle = subtitle..character
				end
			end
		end
	end
	while true do
		currentcharacter = currentcharacter + 1
		if string.sub(code,currentcharacter,currentcharacter) == ";" then
			break
		else
			storedstring = storedstring..string.sub(code,currentcharacter,currentcharacter) 
		end
	end
	width = unbase84(storedstring)+2
	storedstring = ""
	while true do
		currentcharacter = currentcharacter + 1
		if string.sub(code,currentcharacter,currentcharacter) == ";" then
			break
		else
			storedstring = storedstring..string.sub(code,currentcharacter,currentcharacter) 
		end
	end
	height = unbase84(storedstring)+2
	newwidth = width-2
	newheight = height-2
	border = unbase84(string.sub(code,currentcharacter+1,currentcharacter+1))+1
	currentcharacter = currentcharacter + 2
	ClearWorld()
	local data = ""
	while true do
		currentcharacter = currentcharacter + 1
		if string.sub(code,currentcharacter,currentcharacter) == ";" then
			break
		else
			data = data..string.sub(code,currentcharacter,currentcharacter) 
		end
	end
	local celltext = love.data.decompress("string","zlib",love.data.decode("string","base64",data))
	local currentcell = 0
	currentcharacter = 1
	while currentcharacter <= #celltext do
		local character = string.sub(celltext,currentcharacter,currentcharacter)
		if character == "]" then
			currentcharacter = currentcharacter + 1
			character = string.sub(celltext,currentcharacter,currentcharacter)
			local p
			if character == "<" then
				p = ""
				currentcharacter = currentcharacter + 1
				character = string.sub(celltext,currentcharacter,currentcharacter)
				while character ~= "<" do
					p = p..character
					currentcharacter = currentcharacter + 1
					character = string.sub(celltext,currentcharacter,currentcharacter)
				end
			else
				if character == "(" then
					character = string.sub(celltext,currentcharacter+1,currentcharacter+2)
					currentcharacter = currentcharacter + 2
				elseif character == ")" then
					local num = unbase84(string.sub(celltext,currentcharacter+1,currentcharacter+1))
					character = string.sub(celltext,currentcharacter+2,currentcharacter+1+num)
					currentcharacter = currentcharacter + 1+num
				end
				p = unbase84(character)
			end
			local x,y = currentcell%(width-2)+1,math.floor(currentcell/(width-2))+1
			SetPlaceable(x,y,p)
		elseif character == "[" then
			currentcell = currentcell - 1
			currentcharacter = currentcharacter + 1
			character = string.sub(celltext,currentcharacter,currentcharacter)
			local k
			if character == "<" then
				k = ""
				currentcharacter = currentcharacter + 1
				character = string.sub(celltext,currentcharacter,currentcharacter)
				while character ~= "<" do
					k = k..character
					currentcharacter = currentcharacter + 1
					character = string.sub(celltext,currentcharacter,currentcharacter)
				end
			else
				if character == "(" then
					character = string.sub(celltext,currentcharacter+1,currentcharacter+2)
					currentcharacter = currentcharacter + 2
				elseif character == ")" then
					local num = unbase84(string.sub(celltext,currentcharacter+1,currentcharacter+1))
					character = string.sub(celltext,currentcharacter+2,currentcharacter+1+num)
					currentcharacter = currentcharacter + 1+num
				end
				k = unbase84(character)
			end
			currentcharacter = currentcharacter + 1
			character = string.sub(celltext,currentcharacter,currentcharacter)
			local v
			if character == "<" then
				v = ""
				currentcharacter = currentcharacter + 1
				character = string.sub(celltext,currentcharacter,currentcharacter)
				while character ~= "<" do
					v = v..character
					currentcharacter = currentcharacter + 1
					character = string.sub(celltext,currentcharacter,currentcharacter)
				end
			else
				if character == "(" then
					character = string.sub(celltext,currentcharacter+1,currentcharacter+2)
					currentcharacter = currentcharacter + 2
				elseif character == ")" then
					local num = unbase84(string.sub(celltext,currentcharacter+1,currentcharacter+1))
					character = string.sub(celltext,currentcharacter+2,currentcharacter+1+num)
					currentcharacter = currentcharacter + 1+num
				end
				v = unbase84(character)
			end
			local x,y = currentcell%(width-2)+1,math.floor(currentcell/(width-2))+1
			initial[y][x].vars[k] = v
			cells[y][x].vars[k] = v
			currentcell = currentcell + 1
		else
			local x,y = currentcell%(width-2)+1,math.floor(currentcell/(width-2))+1
			if character == "<" then
				local cell = ""
				currentcharacter = currentcharacter + 1
				character = string.sub(celltext,currentcharacter,currentcharacter)
				while character ~= "<" do
					cell = cell..character
					currentcharacter = currentcharacter + 1
					character = string.sub(celltext,currentcharacter,currentcharacter)
				end
				currentcharacter = currentcharacter + 1
				character = string.sub(celltext,currentcharacter,currentcharacter)
				PlaceCell(x,y,{id=cell,rot=tonumber(character),lastvars={x,y,tonumber(character)},vars=DefaultVars(cell)})
			else
				if character == "(" then
					character = string.sub(celltext,currentcharacter+1,currentcharacter+2)
					currentcharacter = currentcharacter + 2
				elseif character == ")" then
					local num = unbase84(string.sub(celltext,currentcharacter+1,currentcharacter+1))
					character = string.sub(celltext,currentcharacter+2,currentcharacter+1+num)
					currentcharacter = currentcharacter + 1+num
				end
				local cell = unbase84(character)
				PlaceCell(x,y,{id=math.floor(cell/4),rot=cell%4,lastvars={x,y,cell%4},vars=DefaultVars(math.floor(cell/4))})
			end
			currentcell = currentcell + 1
		end
		currentcharacter = currentcharacter + 1
	end
	RefreshWorld()
	bgsprites:clear()
	for y=0,height-1 do
		for x=0,width-1 do
			bgsprites:add((x-1)*20,(y-1)*20)
		end
	end
end

function LoadWorld()
	local txt = love.system.getClipboardText()
	if string.sub(txt,1,2) == "V3" then
		DecodeV3(love.system.getClipboardText())
		Play(beep)
	elseif string.sub(txt,1,2) == "K1" then
		DecodeK1(love.system.getClipboardText())
		Play(beep)
	elseif string.sub(txt,1,2) == "K2" then
		DecodeK2(love.system.getClipboardText())
		Play(beep)
	elseif string.sub(txt,1,2) == "K3" then
		DecodeK3(love.system.getClipboardText())
		Play(beep)
	else
		Play(destroysound)
	end
end

function NextLevel()
	if level then
		level = level+1
		if level > #levels then
			mainmenu = 2
			puzzle = true
			inmenu = false
			level = nil
			Play(beep)
		else
			puzzle = true
			DecodeK3(levels[level])
		end
	else
		RefreshWorld()
	end
end

function SaveWorld()
	local currentcell = 0
	local result = "K3"
	if string.len(title) > 0 then
		result = result..":"..title
		if string.len(subtitle) > 0 then
			result = result..":"..subtitle
		end
	end
	result = result..";"
	result = result..base84(width-2)..";"..base84(height-2)..";"
	result = result..base84(border-1)..";"
	local cellcode = ""
	for y=1,height-2 do
		for x=1,width-2 do
			cellcode = cellcode..EncodeCell(x,y)
		end
	end
	cellcode = love.data.encode("string","base64",love.data.compress("string","zlib",cellcode,9))
	result = result..cellcode..";"
	love.system.setClipboardText(result)
	Play(beep)
end

function SetInitial()
	for y=0,height-1 do
		for x=0,width-1 do
			initial[y][x] = {}
			initial[y][x].id = cells[y][x].id
			initial[y][x].rot = cells[y][x].rot
			initial[y][x].lastvars = {x,y,initial[y][x].rot}
			initial[y][x].vars = table.copy(cells[y][x].vars)
		end
	end
	ResetPortals()
	isinitial = true
end

function TogglePause(v)
	if paused ~= v then
		if not v and draggedcell then
			local cx = math.floor((x+cam.x-400*winxm)/cam.zoom)
			local cy = math.floor((y+cam.y-300*winym)/cam.zoom)
			if GetPlaceable(cx,cy) == GetPlaceable(draggedcell.lastvars[1],draggedcell.lastvars[2]) then
				PlaceCell(draggedcell.lastvars[1],draggedcell.lastvars[2],GetCell(cx,cy))
				PlaceCell(cx,cy,draggedcell)
			else
				PlaceCell(draggedcell.lastvars[1],draggedcell.lastvars[2],draggedcell)
			end
		end
		paused = v
		isinitial = isinitial and paused
		buttons.playbtn.icon = paused and 2 or 5
		buttons.playbtn.rot = paused and 0 or math.pi*.5
		buttons.playbtn.name = paused and "Unpause (Space)" or "Pause (Space)"
	end
end

function RotateCW()
	if pasting then
		local oldcopied = table.copy(copied)
		copied = {}
		for y=0,#oldcopied[0] do
			copied[y] = {}
			for x=0,#oldcopied do
				copied[y][x] = oldcopied[#oldcopied-x][y]
				copied[y][x].rot = (copied[y][x].rot+1)%4
				if copied[y][x].vars.gravdir then copied[y][x].vars.gravdir = (copied[y][x].vars.gravdir+1)%4 end
			end
		end
	else
		hudrot,hudlerp = chosen.rot,0
		chosen.rot = (chosen.rot+1)%4
	end
end

function RotateCCW()
	if pasting then
		local oldcopied = table.copy(copied)
		copied = {}
		for y=0,#oldcopied[0] do
			copied[y] = {}
			for x=0,#oldcopied do
				copied[y][x] = oldcopied[x][#oldcopied[0]-y]
				copied[y][x].rot = (copied[y][x].rot-1)%4
				if copied[y][x].vars.gravdir then copied[y][x].vars.gravdir = (copied[y][x].vars.gravdir-1)%4 end
			end
		end
	else
		hudrot,hudlerp = chosen.rot,0
		chosen.rot = (chosen.rot-1)%4
	end
end

function FlipH()
	if pasting then
		local oldcopied = table.copy(copied)
		copied = {}
		for y=0,#oldcopied do
			copied[y] = {}
			for x=0,#oldcopied[0] do
				copied[y][x] = oldcopied[y][#oldcopied[0]-x]
				FlipCellRaw(copied[y][x],0)
				if copied[y][x].vars.gravdir then copied[y][x].vars.gravdir = (-copied[y][x].vars.gravdir+2)%4 end
			end
		end
	else
		hudrot,hudlerp = chosen.rot,0
		chosen.rot = (-chosen.rot+2)%4
	end
end

function FlipV()
	if pasting then
		local oldcopied = table.copy(copied)
		copied = {}
		for y=0,#oldcopied do
			copied[y] = {}
			for x=0,#oldcopied[0] do
				copied[y][x] = oldcopied[#oldcopied-y][x]
				FlipCellRaw(copied[y][x],1)
				if copied[y][x].vars.gravdir then copied[y][x].vars.gravdir = (-copied[y][x].vars.gravdir)%4 end
			end
		end
	else
		hudrot,hudlerp = chosen.rot,0
		chosen.rot = (-chosen.rot)%4
	end
end

function Undo()
	if #undocells > 0 then
		cells = undocells[1]
		isinitial = undocells[1].isinitial
		if isinitial then
			initial = table.copy(undocells[1])
		end
		table.remove(undocells,1)
	end
end

function ChangeZoom(y)
	cam.zoomlevel = math.min(math.max(cam.zoomlevel + y,1),7)
	cam.tarx = cam.tarx*(zoomlevels[cam.zoomlevel]/cam.tarzoom)
	cam.tary = cam.tary*(zoomlevels[cam.zoomlevel]/cam.tarzoom)
	cam.tarzoom = zoomlevels[cam.zoomlevel]
end

function ToggleSelection()
	selection.on = not selection.on
	selection.x = 0
	selection.y = 0
	selection.w = 0
	selection.h = 0
	pasting = false
	buttons.paste.color = pasting and {.5,1,.5,1} or {1,1,1,.5}
	buttons.select.color = selection.on and {.5,1,.5,1} or {1,1,1,.5}
end

function CopySelection()
	if not selection.on then return end
	copied = {}
	for y=0,selection.h-1 do
		copied[y] = {}
		for x=0,selection.w-1 do
			copied[y][x] = CopyCell(x+selection.x,y+selection.y)
		end
	end
	ToggleSelection()
end

function CutSelection()
	if not selection.on then return end
	copied = {}
	for y=0,selection.h-1 do
		copied[y] = {}
		for x=0,selection.w-1 do
			copied[y][x] = CopyCell(x+selection.x,y+selection.y)
			PlaceCell(x+selection.x,y+selection.y,getempty())
		end
	end
	ToggleSelection()
end

function DeleteSelection()
	if not selection.on then return end
	for y=0,selection.h-1 do
		for x=0,selection.w-1 do
			PlaceCell(x+selection.x,y+selection.y,getempty())
		end
	end
	ToggleSelection()
end

function HandleJoystick()
	local jx,jy = love.mouse.getX()-love.graphics.getWidth()+90*uiscale,love.mouse.getY()-love.graphics.getHeight()+120*uiscale
	if jx*jx+jy*jy > 50*50*uiscale*uiscale then
		jx,jy = 0,0
	end
	if freezecam then
		held = math.floor((math.atan2(jy,jx)+(math.pi*.25))*2/math.pi)%4
	else
		cam.tarx,cam.tary = cam.tarx+jx*delta*30/uiscale,cam.tary+jy*delta*30/uiscale
	end
end

function ResetCam()
	cam.x,cam.y,cam.tarx,cam.tary,cam.zoom,cam.tarzoom,cam.zoomlevel = 0,0,0,0,20,20,4
end

levels = {
"K3:First Steps:Welcome to CelLua Machine! Click and drag cells that are on top of a + background, known as a Placeable, to move them. The blue Pusher will constantly move forwards when the simulation is played. The red Enemy will die on contact, and must be killed to proceed. You can start the simulation with the blue button in the top right, or the space key, and restart it with the purple button that appears thereafter.;7;5;1;eNqLtSnISUxOTUzKSbUxiMXJAQGcshbEK0U3NZB4pQakKAUAMzpJLA==;",
"K3:The Pushables:The yellow cells indicate which directions they can be pushed with their lines. For example, if they have lines on the right side, they can be pushed towards the right.;a;9;1;eNqLtSnISUxOTUzKSbUxiKWUAwI4ZS2QOenEmhgYSI5LLIl3owWlvi4g043Z+N2IAgKxsKAAALmGl1Y=;",
"K3:Building Blocks:The green Generator cell will clone the cell behind it and push it out the front.;5;9;1;eNqLtSnISUxOTUzKSbUxiKUPxzJ2ACxNpqE9SCAQCMEAAPBAd60=;",
"K3:Spinning Cells:Rotator cells will rotate nearby cells either clockwise or counter-clockwise, depending on what type of rotator it is. Orange clockwise, cyan counter-clockwise.;a;c;1;eNqLtSnISUxOTUzKSbUxiCWDo2Gog4xwKrQkUoZY86jtPjLNMwABbGIowNHAwBVTFE0bVCcW0cBAHGoBT3d92g==;",
"K3:Garbage Collector:Trash cells will delete any cells that go into them.;b;c;1;eNozMDCItSnISUxOTUzKSbVB4VgSKQMBOBXj1kmSMZbEWWCAD+SAAG6mBZQZiKbAFwRQTQIAg+Zh9g==;",
"K3:Pulling Your Weight:Pullers will attempt to pull every cell behind them. They cannot push.;a;a;1;eNqLtSnISUxOTUzKSbUxiCWOAwHIQhY4FacjcxwxdeLmhBKwkzTXahjqICPKxAKJ1wsAW5BkLQ==;",
"K3:Round The Corner;7;8;1;eNozMDAIBAIDdErDUAeOgNxYm4KcxOTUxKScVBtiOURrS8SnLRSntjTybEO1GgCPxlT+;",
"K3:Turnaround:The purple rotator rotates cells 180 degrees.;9;7;1;eNozMECAQINYm4KcxOTUxKScVBtHiCCykCtEyAJJTxJIG5oyT2yaIAAAlAseWQ==;",
"K3:Strength Increasing:Strong enemies take 2 hits to kill.;f;5;1;eNrTMNTRgKFYm4KcxOTUxKScVBsDVxQebo4GkgGYiEhDyDXeACifDCIotwgnxwJFBgJoaiEKJw1qI4oYcVoTUWQAnzCc3Q==;",
"K3:Advancing Forwards:Advancers can both push and pull.;9;9;1;eNozMEAFgQZ4QKxNQU5icmpiUk6qDQpHw7AMlVuMohS/ZjwcQrYWk6sVn+shWgEsWFio;",
"K3:Double-Cross:Cross Generators act like two generators combined.;8;8;1;eNrTMEzWoAYyMDDQMNQBI5wisTYFOYnJqYlJOak2acgcA2SOhqEFSCcWPQY4OenE6ECVQdIBANG4S4g=;",
"K3:Backflip:Watch what happens when you put the lime Flipper cell next to the Rotator!;9;8;1;eNozMLBMNoAADUMdA0JAwzAZiAxibQpyEpNTE5NyUm3wcGDKDVCEHXFq0DB0hFhDrPkGBgCFoDib;",
"K3:Crossed Paths;9;9;1;eNqLtSnISUxOTUzKSbUxiMXJMTDQMNTRMEwGkzrIUo7InHRkjoZhsQFYI1BXciwJ9hhg2jI4tKRjaknCp8XAwBVfaGGxoYp0R8ERAK/Pkc8=;",
"K3:Change of Sides:Here, you'll have to move the enemies so that the pushers can destroy all of them!;a;a;1;eNpzNDCItSnISUxOTUzKSbUhlmNg4OqIqlPDMBmn8kAMva64zcZnEFDOwBHdZtxWoRsFcTUEuDpaQBiJYBZIAsJKSkJjGQChqwEQAgBAcl/T;",
"K3:Repulsive:Repulsors will push the cells around it away from it.;b;5;1;eNqLtSnISUxOTUzKSbUxiCWKY4EiAwIahjpARKQG3ByIUQb4jELhOOI3yiAQRSibBA8Z+JLjfmROOsQjEOQLxACbb3ik;",
"K3:Around the World:Something's different about the border this time...;b;b;b;eNqLtSnISUxOTUzKSbUxiCWDo2GoYwACxClPpZZBuDlhBA2yJNFrUBpIOYIAgouJoBKBQGBAJhdsJQCgJ3m1;",
"K3:Mirroring:Mirror cells will swap the two cells adjacent to them according to the arrows.;a;a;1;eNqLtSnISUxOTUzKSbUxiCWOAwHIQpZk68TNSUHT6Ui0TvLtRNcZSW87XQnoTMRrp4ahDgSR6eYcsn2bYxAIALMcxkY=;",
"K3:Diversion:Diverters will divert whatever comes in according to the arrow on it.;a;a;1;eNozMIADCwgVa1OQk5icmpiUk2qjbYACkKXUULmquFVqowvoGqCBQOzmowsh2wEA2/MxtQ==;",
"K3:Rotatables:You can click on cells that are on top of an orange background (outlined with orange) to rotate them.;e;b;1;eNozMMAKYm2K8ksSSxKTclJtNAzdMPhowMLAAogw9Lk6ovHJsgfdDAJuIdIN5LpGwzAZRQ+UDwCmxFq8;",
"K3:Cycles:These generators will generate at an angle. The darker grey walls are generatable walls.;c;c;1;eNrTMNTRQEHJGugiKMjXwMAEl5yBQSoenQZAgCYEMskg1qYgJzE5NTEpJ9UGN0fDMA9FzsDAF2psCpq6bOIMhDgH6NtkIANZIolY/WkG8CDB4+xcVG4OqhnQQCAQTsgoGbesCTxQcCP06AUA3WeCfw==;",
"K3:Grasping Colors:Graspers will hold onto a row of cells perpendicular to it's direction. Cells on Placeables of different colors cannot swap with eachother.;f;9;1;eNozMACCQBAwwAJibQpyEpNTE5NyUm2I5RjkgABNtWsYVyBzLbAZgCQWZEM8LxxsM0EjNIyr8BlJnCEGBI1AA4h4AgAXPJAW;",
"K3:Precision:Kill the enemies without causing the barrier to form!;A;e;1;eNrTMNTRoCoy0DAL1zDUQ0NqOHWYOJKHUjTMwtCEgJbY4nSWQaABDKCywJrw6MMFKNMXa1OQk5icmpiUk2pjQCknGbcyst1hgVMmmxwX0jo8XIn0CHXc4YhTJodIt9MqXdFIH5bMg1+fhokreShNwywUXdSwWluDBuVUBFohBbIEAO3JOXg=;",
"K3:Safecracking:The rotator with yellow sides will only rotate cells next to the sides that aren't yellow.;g;b;1;eNqLtSnISUxOTUzKSbUxiCWDgwSI05FORbNId1c+GWZpGOeAzckGghwquSwHaFQOWYGEzAmFmJWjYZicQzWX5RDvy1CcMo4wX2Zno4i70iWNoXAs6JHGAKrkHI4=;",
"K3:Redirection:Redirectors will force cells to face the same way it is facing!;e;e;2;eNqLtSnISUxOTUzKSbUxiCWdkxRLoQEDwrGl1ABL2rnNfiACRI9i02CAum40yMkGghwqx4pBDtDYnBxyEnISXlMDA3NyKI5Ze9JMJTNcMUOAYo4labFFScqyHPAiRI9O9hCZLuOGZDk8MDEHAHEPdt0=;",
"K3:Weighing Your Options:The weight cell requires an extra pusher to be pushed!;c;a;1;eNrTMNTRgKF0BKVqoKaBJJOCoAySNUycYm0KchKTUxOTclJtDHByHFFk0pF4QSgKg1AlnUCSRfkliSVgjRCH2BJpCx4rA1F5qFYGIlupTcBKA2KtNMBnpQEpViZR30pgwFZrI8cyGjKwxSMJkscjZwGUNAnEo0BPwzAZJA8AKn/BtA==;",
"K3:Chilled Out:Freezers will prevent the four cells around it from functioning.;9;a;1;eNqLtSnISUxOTUzKSbUxiMXFScQpYwACyAKOyBwNwxJkbihOY0LRjUmPJcph6XjdYoDqFtxmRmC4RcNQBxmBhAINCAGEWqBqCAcAefFvLA==;",
"K3:Pipe Dream;a;6;1;eNqLtSnISUxOTUzKSbUxMIi1KcovSSwB8zQM3TQMqyEkmjgqtxqkD48pKFwTR5ChJmhqXNG0oJpoYQBxCJq1aEagm2LiYRCI6i4Mt7gQ8Bq6M93w+9QV3UUmhnidDAwHQ3QTCXoTzY8YMeZqYAAASrScBg==;",
"K3:Control:The player cell can be controlled while the simulation is running! It has the ability to push cells. If it dies, you'll have to restart.;a;a;1;eNozMIADjaRyAwygYagDR77ZQAAWzUGSgPKhoABJI5QVCGZHoosDABGEGO8=;",
"K3:Locked Away: Key cells can open Door cells when pushed into them!;a;a;b;eNozMPA1gAAN83wE21AHgpCYMAEwgCkEsYAaMRRhakER0UgqxxCDOqIYiALBalDNhCMA7nAh8Q==;",
}

local bactive = function() return inmenu and not winscreen and not mainmenu end
local optionbactive = function() return inmenu and not winscreen and not mainmenu or mainmenu == 3 end
local strictbactive = function() return inmenu and not level and not mainmenu end
local stricterbactive = function() return inmenu and not puzzle and not mainmenu end
local wactive = function() return winscreen and not mainmenu end
local mble = function() return mobile and not mainmenu end
local mbleandnopuz = function() return mobile and not puzzle and not mainmenu end
local mmenu1 = function() return mainmenu == 1 end
local mmenu2 = function() return mainmenu == 2 end
local exitbtn = function() return mainmenu == 2 or mainmenu == 3 end
NewButton(20,20,40,40,"menu","menu","Menu",nil,function() inmenu = not inmenu and not winscreen end,false,function() return not mainmenu end,"topleft")
NewButton(70,20,40,40,"zoomin","zoomin","Zoom In",nil,function() ChangeZoom(1) end,false,mble,"topleft")
NewButton(120,20,40,40,"zoomout","zoomout","Zoom Out",nil,function() ChangeZoom(-1) end,false,mble,"topleft")
NewButton(170,20,40,40,"eraser","erase","Eraser",nil,function() SetSelectedCell("eraser") end,false,mbleandnopuz,"topleft")
NewButton(220,20,40,40,"brushup","brushup","Increase Brush Size",nil,function() chosen.size = chosen.size + 1 end,false,mbleandnopuz,"topleft")
NewButton(20,70,40,40,"select","select","Select (Tab)",nil,ToggleSelection,false,mbleandnopuz,"topleft")
NewButton(70,70,40,40,"copy","copy","Copy Selected (Ctrl+C)",nil,CopySelection,false,mbleandnopuz,"topleft")
NewButton(120,70,40,40,"cut","cut","Cut Selected (Ctrl+X)",nil,CutSelection,false,mbleandnopuz,"topleft")
NewButton(170,70,40,40,"delete","remove","Delete Selected (Backspace)",nil,DeleteSelection,false,mbleandnopuz,"topleft")
NewButton(220,70,40,40,"brushdown","brushdown","Decrease Brush Size",nil,function() chosen.size = math.max(1,chosen.size - 1) end,false,mbleandnopuz,"topleft")
NewButton(20,120,40,40,9,"rotatecw","Rotate CW (E)",nil,RotateCW,false,mbleandnopuz,"topleft")
NewButton(70,120,40,40,10,"rotateccw","Rotate CCW (Q)",nil,RotateCCW,false,mbleandnopuz,"topleft")
NewButton(120,120,40,40,15,"fliph","Flip Horizontally (Ctrl+Q)",nil,FlipH,false,mbleandnopuz,"topleft")
NewButton(170,120,40,40,15,"flipv","Flip Vertically (Ctrl+E)",nil,FlipV,false,mbleandnopuz,"topleft",math.pi*.5)
NewButton(20,170,40,40,"paste","paste","Paste (Ctrl+V)",nil,function() pasting = copied[0] and not pasting; buttons.paste.color = pasting and {.5,1,.5,1} or {1,1,1,.5} end,false,function() return copied[0] and mobile and not puzzle and not mainmenu end,"topleft")
NewButton(20,20,40,40,2,"playbtn","Unpause (Space)",nil,function() TogglePause(not paused) end,false,mble,"topright")
NewButton(70,20,40,40,17,"stepbtn","Step (F)",nil,function() for i=1,tpu do DoTick(i==1) end TogglePause(true) end,false,mble,"topright")
NewButton(120,20,40,40,14,"undobtn","Undo (Ctrl+Z)",nil,Undo,false,function() return mobile and not mainmenu and #undocells > 0 end,"topright",math.pi)
NewButton(20,70,40,40,11,"resetlvl","Reset (Ctrl+R)",nil,RefreshWorld,false,function() return not isinitial and mobile and not mainmenu end,"topright")
NewButton(70,70,40,40,146,"setinitial","Set Initial","Sets the initial state to the current state.",SetInitial,false,function() return not isinitial and not puzzle end,"topright")
NewButton(40,70,100,100,"joystickbg","joystick",nil,nil,HandleJoystick,true,mble,"bottomright",nil,{1,1,1,1},{1,1,1,1},{1,1,1,1})
NewButton(0,0,400,300,"menubg","menubg",nil,nil,function() end,false,function() return (inmenu or winscreen) and not mainmenu end,"center",nil,{1,1,1,1},{1,1,1,1},{1,1,1,1})
NewButton(-150,100,40,40,2,"closemenu","Close Menu",nil,function() inmenu = false Play(beep) end,false,bactive,"center")
NewButton(-100,100,40,40,11,"resetlvlmenu","Reset Level","Also resizes the world to the values specified above.\n(In Sandbox Mode)",RefreshWorld,false,bactive,"center")
NewButton(-50,100,40,40,9,"resetpuzzlemenu","Reset Puzzle","Resets the puzzle to how it was in the beginning.",function() level = level - 1; NextLevel() end,false,function() return level and inmenu end,"center")
NewButton(-50,100,40,40,12,"clearlvl","Clear Level","Also resizes the world to the values specified above.",function() title,subtitle = "",""; ClearWorld() Play(beep) end,false,strictbactive,"center")
NewButton(0,100,40,40,3,"savelvl","Save level","Saves to clipboard. Format: K3",SaveWorld,false,strictbactive,"center", -math.pi*.5)
NewButton(50,100,40,40,"mode","loadlvl","Load & Edit Level","Fetches from clipboard.\nLoads V3 and K1-K3 codes.",function() LoadWorld(); puzzle = false end,false,strictbactive,"center")
NewButton(100,100,40,40,"puzzle","puzzleloadlvl","Load Level as Puzzle","Fetches from clipboard.\nLoads V3 and K1-K3 codes.",function() LoadWorld(); puzzle = true; SetSelectedCell("eraser") end,false,strictbactive,"center")
NewButton(150,100,40,40,"delete","tomainmenu","Back to Main Menu",nil,function() mainmenu = 1; puzzle = true; inmenu = false; Play(beep) end,false,bactive,"center",nil,{1,.5,.5,.5},{1,.5,.5,1},{.5,.25,.25,1})
NewButton(0,-105,300,10,"pix","delayslider",nil,nil,function() delay =  math.round((love.mouse.getX()/uiscale-centerx/uiscale+150)/3)*.01 end,true,bactive,"center",nil,{.25,.25,.25,1},{.25,.25,.25,1},{.25,.25,.25,1})
NewButton(0,-83,300,10,"pix","tpuslider",nil,nil,function() tpu = math.round((love.mouse.getX()/uiscale-centerx/uiscale+150+33.3333333)/33.3333333) end,true,bactive,"center",nil,{.25,.25,.25,1},{.25,.25,.25,1},{.25,.25,.25,1})
NewButton(0,-61,300,10,"pix","volumeslider",nil,nil,function() volume = math.round((love.mouse.getX()/uiscale-centerx/uiscale+150)/3)*.01 music:setVolume(volume) music2:setVolume(volume) music3:setVolume(volume) end,true,optionbactive,"center",nil,{.25,.25,.25,1},{.25,.25,.25,1},{.25,.25,.25,1})
NewButton(0,-39,300,10,"pix","svolumeslider",nil,nil,function() svolume = math.round((love.mouse.getX()/uiscale-centerx/uiscale+150)/3)*.01 beep:setVolume(svolume) destroysound:setVolume(svolume) unlocksound:setVolume(svolume) movesound:setVolume(svolume*4) rotatesound:setVolume(svolume*.5) infectsound:setVolume(svolume*3) coinsound:setVolume(svolume*.5) end,true,optionbactive,"center",nil,{.25,.25,.25,1},{.25,.25,.25,1},{.25,.25,.25,1})
NewButton(0,-17,300,10,"pix","borderslider",nil,nil,function() if not puzzle then border = math.round((love.mouse.getX()/uiscale-centerx/uiscale+150+300/(#bordercells-1))/(300/(#bordercells-1))) end end,true,stricterbactive,"center",nil,{.25,.25,.25,1},{.25,.25,.25,1},{.25,.25,.25,1})
NewButton(0,5,300,10,"pix","uiscaleslider",nil,nil,function() newuiscale = math.round((love.mouse.getX()/uiscale-centerx/uiscale+250)/2)*.01 end,true,optionbactive,"center",nil,{.25,.25,.25,1},{.25,.25,.25,1},{.25,.25,.25,1})
NewButton(0,25,20,20,"debug","debugbtn","Debug mode",nil,function(b) dodebug = not dodebug b.icon = dodebug and "checkon" or "debug" end,false,optionbactive,"center",nil,{.5,.5,.5,1},{.75,.75,.75,1},{.25,.25,.25,1})
NewButton(-25,25,20,20,"subtick","subtickbtn","Subticking",nil,function(b) subticking = not subticking b.icon = subticking and "checkon" or "subtick" end,false,optionbactive,"center",nil,{.5,.5,.5,1},{.75,.75,.75,1},{.25,.25,.25,1})
NewButton(25,25,20,20,"checkon","fancybtn","Fancy Graphics",nil,function(b) fancy = not fancy b.icon = fancy and "checkon" or "fancy" end,false,optionbactive,"center",nil,{.5,.5,.5,1},{.75,.75,.75,1},{.25,.25,.25,1})
NewButton(-50,25,20,20,"checkon","mobilebtn","Extended UI",nil,function(b) mobile = not mobile; b.icon = mobile and "checkon" or "bigui"; buttons.setinitial.x,buttons.setinitial.y,buttons.resetlvl.y=mobile and 70 or 20,mobile and 70 or 20,mobile and 70 or 20 end,false,optionbactive,"center",nil,{.5,.5,.5,1},{.75,.75,.75,1},{.25,.25,.25,1})
NewButton(50,25,20,20,"music","musicbtn","Change Music",nil,function() if music:tell() > 0 then music:stop() music2:play() elseif music2:tell() > 0 then music2:stop() music3:play() else music:play() music3:stop() end end,false,optionbactive,"center",nil,{.5,.5,.5,1},{.75,.75,.75,1},{.25,.25,.25,1})
NewButton(-75,25,20,20,"checkon","popups","Show Pop-up Info",nil,function(b) showinfo = not showinfo b.icon = showinfo and "checkon" or "popups" end,false,optionbactive,"center",nil,{.5,.5,.5,1},{.75,.75,.75,1},{.25,.25,.25,1})
NewButton(-75,62,50,25,"pix","widthbtn",nil,nil,function() if not puzzle then typing = 1 end end,false,stricterbactive,"center",nil,{.25,.25,.25,1},{.25,.25,.25,1},{.25,.25,.25,1})
NewButton(75,62,50,25,"pix","heightbtn",nil,nil,function() if not puzzle then typing = 2 end end,false,stricterbactive,"center",nil,{.25,.25,.25,1},{.25,.25,.25,1},{.25,.25,.25,1})
NewButton(-80,80,60,60,2,"nextlvlwin","Next Level",nil,function() NextLevel() Play(beep) winscreen = false end,false,wactive,"center")
NewButton(0,80,60,60,11,"replaylvlwin","Replay Solution",nil,RefreshWorld,false,wactive,"center")
NewButton(80,80,60,60,9,"resetlvlwin","Reset Level",nil,function() level = level and level-1; NextLevel() Play(beep) winscreen = false end,false,wactive,"center")
NewButton(-80,100,60,60,"puzzle","puzzlescreen","Puzzles",nil,function() mainmenu = 2; delay = .2; tpu = 1; Play(beep) end,false,mmenu1,"center")
NewButton(0,100,60,60,105,"optionsbtn","Options",nil,function() mainmenu = 3; Play(beep) end,false,mmenu1,"center")
NewButton(80,100,60,60,2,"startgamebtn","Sandbox",nil,function() mainmenu = false; newwidth = 100; newheight = 100; border = 2; delay = .2; tpu = 1; title,subtitle = "",""; ClearWorld(); puzzle = false; level = nil ResetCam() Play(beep) end,false,mmenu1,"center")
NewButton(20,20,40,40,"delete","backtomain","Go Back",nil,function() mainmenu = 1 Play(beep) end,false,exitbtn,"topleft")
local xamnt = math.ceil(math.sqrt(#levels))+1	-- +1 so the layout will stay more rectangular to fit the screen better
local xoff = 25*(xamnt-1)
local yoff = 25*math.floor((#levels-1)/xamnt)
for i=0,#levels-1 do
	NewButton(50*(i%xamnt)-xoff,50*math.floor(i/xamnt)-yoff,40,40,"checkoff","topuzzle"..i+1,nil,nil,function() level = i; NextLevel() ResetCam() Play(beep) end,false,mmenu2,"center")
end

function ToSide(rot,dir)	--laziness (converts rotation of cell & direction of force -> the side that the force is being applied to)
	return (dir-rot+2)%4
end

function GetNeighbors(x,y)	--4 neighbors
	return {[0]={x+1,y},{x,y+1},{x-1,y},{x,y-1}}
end

function GetSurrounding(x,y)	--8 neighbors
	return {[0]={x+1,y},[0.5]={x+1,y+1},[1]={x,y+1},[1.5]={x-1,y+1},[2]={x-1,y},[2.5]={x-1,y-1},[3]={x,y-1},[3.5]={x+1,y-1}}
end

function GetDiagonals(x,y)	--4 diagonal neighbors
	return {[0.5]={x+1,y+1},[1.5]={x-1,y+1},[2.5]={x-1,y-1},[3.5]={x+1,y-1}}
end

function IsUnbreakable(cell,dir,x,y,vars)
	local id = cell.id
	local rot = cell.rot
	local side = ToSide(rot,dir)
	if type(ModStuff.unbreakable[id]) == "function" then
		return ModStuff.unbreakable[id](id, dir, x, y, vars, side)
	end
	return id == 1 or id == 41 or (id == 69 or id == 213) and side ~= 0 and side ~= 2 or id == 140 and side ~= 2 and side ~= 1 or id == 157 and side ~= 2 or id == 158 and side ~= 3 and side ~= 2 and side ~= 1 or id == 159 and side%1 ~= 0
	or id == 12 or id == 51 or id == 141 or id == 205 or id == 176 or id == 126 or id == 150 or id == 151 or id == 152 or id == 162 or id == 229 or id == 163 or id == 165 or id == 221 or id == 224 or id == 225 or id == 226 and (side == 0 or side == 2) or id == 300 and side == 0
	or id == 154 and vars.lastcell.id ~= 153 or cell.bolted and vars.forcetype == "swap" or cell.reinforced and vars.forcetype == "scissor" or id == "wrap" or id == 199 or id == 200 or id == 201 or id == 202 or id == 203 or id == 204 or
	(id == 206 or id == 234 or id == 240 or id == 241) and vars.forcetype == "infect" or (id == 234 or id == 240 or id == 241 or id == 242 or id == 243) and vars.forcetype == "burn" or id == 235
	or cell.protected and (vars.forcetype == "destroy" or vars.forcetype == "infect" or vars.forcetype == "burn" or vars.forcetype == "transform")
end

function IsNonexistant(cell,dir,x,y)	--act like empty space
	if type(ModStuff.nonexistant[cell.id]) == "function" then
		return ModStuff.nonexistant[cell.id](cell, dir, x, y)
	end
	return cell.id == 0 or cell.id == 116 or cell.id == 117 or cell.id == 118 or cell.id == 119 or cell.id == 120 or cell.id == 121 or cell.id == 122 or cell.id == 223 or cell.id == "wrap"
end

function IsDestroyer(cell,dir,x,y,vars)
	local id = cell.id
	local rot = cell.rot
	local side = ToSide(rot,dir)
	vars.lastcell = vars.lastcell or getempty()
	if type(ModStuff.destroyers[id]) == "function" then
		return ModStuff.destroyers[id](cell, dir, x, y, vars)
	end
	if type(ModStuff.acidic[vars.lastcell.id]) == "function" then
		return ModStuff.acidic[vars.lastcell.id](cell, dir, x, y, vars)
	end
	return ((id == 13 or id == 24 or id == 160 or id == 163 or id == 164 or id == 244 or id == 288 or id == 293 or id == 294 or id == 295 or id == 296 or id == 298 or id == 299
	or (vars.lastcell.id == 13 or vars.lastcell.id == 24 or vars.lastcell.id == 160 or vars.lastcell.id == 164 or vars.lastcell.id == 244 or vars.lastcell.id == 288 or vars.lastcell.id == 293 or vars.lastcell.id == 294 or vars.lastcell.id == 295 or vars.lastcell.id == 296 or vars.lastcell.id == 298 or vars.lastcell.id == 299
	or (vars.lastcell.id == 219 or vars.lastcell.id == 220) and id ~= 219 and id ~= 220 and (vars.forcetype == "push" or vars.forcetype == "nudge")) and vars.forcetype ~= "swap")
	and not IsUnbreakable(cell,dir,x,y,{forcetype="destroy",lastcell=vars.lastcell}) and not IsNonexistant(cell,dir,x,y,vars)
	or (id == 44 and side == 0 or id == 155 and (side == 0 or side == 3) or id == 250 and (side == 0 or side == 2) or id == 251)
	and (vars.forcetype == "push" or vars.forcetype == "nudge" or vars.forcetype == "scissor") or id == 154 and vars.lastcell.id == 153)
	and not IsUnbreakable(vars.lastcell,(dir+2)%4,x,y,{forcetype="destroy",lastcell=cell})
	or id == 12 or id == 51 or id == 141 or id == 176 or id == 205 or (id == 225 or id == 226) and (side == 0 or side == 2) or id == 300 and side == 0
	or id == 165 or id == 175 and (cell.updatekey == updatekey or not cell.vars[1]) or id == 198 and side == 2 or id == 233
	or ((id == 48 or id == 49 or id == 97 or id == 98 or id == 99 or id == 100 or id == 101 or id == 102) and side == 2
	or (id == 186 or id == 187 or id == 189 or id == 190 or id == 191 or id == 193) and side == 3
	or (id == 187 or id == 188 or id == 189 or id == 191 or id == 192 or id == 193) and side == 2
	or (id == 186 or id == 187 or id == 188 or id == 190 or id == 191 or id == 192) and side == 1)
	and (vars.forcetype == "push" or vars.forcetype == "nudge" or vars.forcetype == "scissor")
	or (id == 32 or id == 33 or id == 34 or id == 35 or id == 36 or id == 37 or id == 194 or id == 195 or id == 196 or id == 197) and (side == 1 or side == 3)
end

function IsTransparent(cell,dir,x,y,vars)
	if type(ModStuff.transparent[cell.id]) == "function" then
		return ModStuff.transparent[cell.id](cell, dir, x, y, vars)
	end
	return (IsNonexistant(cell,dir,x,y,vars) or IsDestroyer(cell,dir,x,y,vars))
end

function ToGenerate(cell,dir,x,y)
	local id = cell.id
	local rot = cell.rot
	local side = ToSide(rot,dir)
	if type(ModStuff.toGenerates[cell.id]) == "function" then
		return ModStuff.toGenerates[cell.id](cell, dir, x, y, side) 
	end
	if id == 20 then
		return getempty()
	elseif IsNonexistant(cell,dir,x,y) or id == 41 or id == 205 or id == 214 or id == 215 or id == 216 or id == 217 or id == 218 then
		return nil
	end
	return cell
end

function StopsOptimize(cell,dir,x,y,vars)
	if type(ModStuff.stopOptimization[cell.id]) == "function" then
		return ModStuff.stopOptimization[cell.id](cell, dir, x, y, vars)
	end
	return IsTransparent(cell,dir,x,y,vars) or cell.id == 126 or cell.id == 150 or cell.id == 151 or cell.id == 152 or cell.id == 162 or cell.id == 163 or
	(cell.id == 168 or cell.id == 167 or cell.id == 169 or cell.id == 170 or cell.id == 171 or cell.id == 172 or cell.id == 173 or cell.id == 174) and cell.rot == dir
	or cell.id == 219 or cell.id == 220
end

function NextCell(x,y,dir,lastcell,reversed,checkfirst,determinative)	--i know it's a weirdly named function
	lastcell = lastcell or getempty()
	local firstloop = true
	while true do
		if checkfirst or not firstloop then
			local cell = GetCell(x,y)
			local id = cell.id
			local side = ToSide(cell.rot,dir)
			if id == 16 or id == 91 then
				if side == 0 then
					if id == 16 then lastcell.rot = (lastcell.rot - 1)%4 end
					dir = (dir - 1)%4
				elseif side == 1 then
					if id == 16 then lastcell.rot = (lastcell.rot + 1)%4 end
					dir = (dir + 1)%4
				else goto stop end
			elseif id == 31 or id == 92 then
				if side == 0 or side == 2 then
					if id == 31 then lastcell.rot = (lastcell.rot - 1)%4 end
					dir = (dir - 1)%4
				elseif side == 1 or side == 3 then
					if id == 31 then lastcell.rot = (lastcell.rot + 1)%4 end
					dir = (dir + 1)%4
				else goto stop end
			elseif id == 38 then
				if side == 1 or side == 3 then goto stop end
			elseif id == 210 then
				if side == 1 or side == 3 then goto stop
				else FlipCellRaw(lastcell,(cell.rot+1)%4) end
			elseif id == 93 or id == 95 then
				if reversed then
					if side ~= 0 then goto stop end
				else
					if side == 1 then
						if id == 93 then lastcell.rot = (lastcell.rot + 1)%4 end
						dir = (dir + 1)%4
					elseif side ~= 2 then goto stop end
				end
			elseif id == 94 or id == 96 then
				if reversed then
					if side ~= 0 then goto stop end
				else
					if side == 3 then
						if id == 94 then lastcell.rot = (lastcell.rot - 1)%4 end
						dir = (dir - 1)%4
					elseif side ~= 2 then goto stop end
				end
			elseif id == 83 or id == 86 then
				if reversed then
					if side ~= 2 then goto stop end
				else
					if side == 1 then
						if id == 83 then lastcell.rot = (lastcell.rot + 1)%4 end
						dir = (dir + 1)%4
					elseif side == 3 then
						if id == 83 then lastcell.rot = (lastcell.rot - 1)%4 end
						dir = (dir - 1)%4
					elseif side == 0 then goto stop end
				end
			elseif id == 84 or id == 87 then
				if side == 1 or side == 3 then
					if reversed then goto stop end
					if id == 84 then lastcell.rot = (lastcell.rot + 1)%4 end
					dir = (dir + 1)%4
				end
			elseif id == 85 or id == 88 then
				if side == 1 or side == 3 then
					if reversed then goto stop end
					if id == 85 then lastcell.rot = (lastcell.rot - 1)%4 end
					dir = (dir - 1)%4
				end
			elseif id == 208 or id == 300 then
				if side ~= 0 and reversed or side ~= 2 and not reversed or side == 1 or side == 3 then
					goto stop
				end
			elseif id == 209 then
				if side ~= 0 and side ~= 3 and reversed or side ~= 2 and side ~= 1 and not reversed then
					goto stop
				end
			elseif (id == 48 or id == 99) and reversed then
				if side == 1 then
					if id == 48 then lastcell.rot = (lastcell.rot - 1)%4 end
					dir = (dir - 1)%4
				elseif side == 3 then
					if id == 48 then lastcell.rot = (lastcell.rot + 1)%4 end
					dir = (dir + 1)%4
				else goto stop end
			elseif (id == 49 or id == 100) and reversed then
				if side == 1 then
					if id == 49 then lastcell.rot = (lastcell.rot - 1)%4 end
					dir = (dir - 1)%4
				elseif side == 3 then
					if id == 49 then lastcell.rot = (lastcell.rot + 1)%4 end
					dir = (dir + 1)%4
				elseif side == 2 then goto stop end
			elseif (id == 97 or id == 101) and reversed then
				if side == 1 then
					if id == 97 then lastcell.rot = (lastcell.rot - 1)%4 end
					dir = (dir - 1)%4
				elseif side ~= 0 then goto stop end
			elseif (id == 98 or id == 102) and reversed then
				if side == 3 then
					if id == 98 then lastcell.rot = (lastcell.rot + 1)%4 end
					dir = (dir + 1)%4
				elseif side ~= 0 then goto stop end
			elseif (id == 186 or id == 190) and reversed then
				if side == 0 then
					if id == 186 then lastcell.rot = (lastcell.rot - 1)%4 end
					dir = (dir - 1)%4
				else goto stop end
			elseif (id == 187 or id == 188 or id == 189 or id == 191 or id == 192 or id == 193) and reversed then
				if side ~= 0 then goto stop end
			elseif id == 221 then
				if not reversed then
					local options = portals[cell.vars[2]] or {}
					if #options ~= 0 then
						x,y = unpack(options[determinative and 1 or math.random(#options)])	--apparently this function exists
						local cell2 = GetCell(x,y)
						local change = cell2.rot-cell.rot
						dir = (dir+change)%4
						lastcell.rot = (lastcell.rot+change)%4
					end
				else
					local options = reverseportals[cell.vars[1]] or {}
					if #options ~= 0 then
						x,y = unpack(options[determinative and 1 or math.random(#options)])
						local cell2 = GetCell(x,y)
						local change = cell2.rot-cell.rot
						dir = (dir+change)%4
						lastcell.rot = (lastcell.rot+change)%4
					end
				end
			elseif id == 224 and lastcell.vars.coins and lastcell.vars.coins >= cell.vars[1] then
				lastcell.vars.coins = lastcell.vars.coins-cell.vars[1]
				if lastcell.vars.coins <= 0 then
					lastcell.vars.coins = nil
				end
			elseif id == 233 then
				if lastcell.id == cell.vars[1] or side == 1 or side == 3 then
					goto stop
				end
			elseif id ~= 39 and (not IsNonexistant(cell,dir,x,y) or
			((dir == 0 or dir == 2) and (GetCell(x,y-1).id ~= 79 and GetCell(x,y+1).id ~= 79) or
			((dir == 1 or dir == 3) and (GetCell(x-1,y).id ~= 79 and GetCell(x+1,y).id ~= 79)))) then goto stop end
			local data = GetData(x,y)
			if data.updatekey == updatekey and data.crosses >= 5 then
				return
			else
				data.crosses = data.updatekey == updatekey and data.crosses + 1 or 1
			end
			data.updatekey = updatekey
		end
		::redo::
		if dir == 0 then x = x + 1
		elseif dir == 2 then x = x - 1
		elseif dir == 1 then y = y + 1
		else y = y - 1 end
		if cells[0][0].id == "wrap" then
			if x > width-2 then
				lastcell.lastvars = table.copy(lastcell.lastvars)
				lastcell.lastvars[1] = 0
				x = 1
			elseif x < 1 then
				lastcell.lastvars = table.copy(lastcell.lastvars)
				lastcell.lastvars[1] = width-1
				x = width-2
			end
			if y > height-2 then
				lastcell.lastvars = table.copy(lastcell.lastvars)
				lastcell.lastvars[2] = 0
				y = 1
			elseif y < 1 then
				lastcell.lastvars = table.copy(lastcell.lastvars)
				lastcell.lastvars[2] = height-1
				y = height-2
			end
		end
		firstloop = false
		goto loop
		::stop::
		if firstloop then goto redo
		else break end
		::loop::
	end
	return x,y,dir,lastcell
end

function RotateCell(x,y,rot,dir,large)
	local cell = GetCell(x,y)
	if cell.locked then return end
	if cell.id == 105 and updatekey ~= cell.updatekey then
		cell.rot = (cell.rot+rot)%4
		cell.updatekey = updatekey
		local neighbors = large and GetSurrounding(x,y) or GetNeighbors(x,y)
		for k,v in pairs(neighbors) do
			RotateCell(v[1],v[2],rot,k,large)
		end
	elseif not IsUnbreakable(cell,dir,x,y,{forcetype="rotate",lastcell=getempty()}) and not IsNonexistant(cell,dir,x,y) then
		cell.rot = (cell.rot+rot)%4
		Play(rotatesound)
	end
	if type(ModStuff.whenRotated[cell.id]) == "function" then
		ModStuff.whenRotated[cell.id](cell, x, y, dir, rot)
	end
end

function RotateCellTo(x,y,rot,dir)
	local cell = GetCell(x,y)
	if cell.locked then return end
	if cell.id == 105 and updatekey ~= cell.updatekey then
		cell.rot = rot
		cell.updatekey = updatekey
		local neighbors = GetNeighbors(x,y)
		for k,v in pairs(neighbors) do
			RotateCellTo(v[1],v[2],rot,k)
		end
	elseif not IsUnbreakable(cell,dir,x,y,{forcetype="rotate",lastcell=getempty()}) and ConvertId(cell.id) ~= 17 and not IsNonexistant(cell,dir,x,y) then
		cell.rot = rot
		Play(rotatesound)
	end
end

function FlipCellRaw(cell,rot)
	--convert cell id to flipped variant (i.e. clockwise to counter-clockwise)
	if type(ModStuff.idConversion[cell.id]) == "function" then
		return ModStuff.idConversion[cell.id](cell, rot)
	end

	if cell.id == 9 then cell.id = 10 elseif cell.id == 10 then cell.id = 9
	elseif cell.id == 18 then cell.id = 19 elseif cell.id == 19 then cell.id = 18
	elseif cell.id == 26 then cell.id = 27 elseif cell.id == 27 then cell.id = 26
	elseif cell.id == 64 then cell.id = 65 elseif cell.id == 65 then cell.id = 64
	elseif cell.id == 66 then cell.id = 67 elseif cell.id == 67 then cell.id = 66
	elseif cell.id == 81 then cell.id = 82 elseif cell.id == 82 then cell.id = 81
	elseif cell.id == 84 then cell.id = 85 elseif cell.id == 85 then cell.id = 84
	elseif cell.id == 87 then cell.id = 88 elseif cell.id == 88 then cell.id = 87
	elseif cell.id == 93 then cell.id = 94 elseif cell.id == 94 then cell.id = 93
	elseif cell.id == 95 then cell.id = 96 elseif cell.id == 96 then cell.id = 95
	elseif cell.id == 97 then cell.id = 98 elseif cell.id == 98 then cell.id = 97
	elseif cell.id == 101 then cell.id = 102 elseif cell.id == 102 then cell.id = 101
	elseif cell.id == 108 then cell.id = 109 elseif cell.id == 109 then cell.id = 108
	elseif cell.id == 112 then cell.id = 111 elseif cell.id == 111 then cell.id = 110
	elseif cell.id == 150 then cell.id = 151 elseif cell.id == 151 then cell.id = 150
	elseif cell.id == 169 then cell.id = 170 elseif cell.id == 170 then cell.id = 169
	elseif cell.id == 173 then cell.id = 174 elseif cell.id == 174 then cell.id = 173
	elseif cell.id == 183 then cell.id = 182 elseif cell.id == 182 then cell.id = 183
	elseif cell.id == 185 then cell.id = 184 elseif cell.id == 184 then cell.id = 185
	elseif cell.id == 118 then cell.id = 189 elseif cell.id == 189 then cell.id = 118
	elseif cell.id == 192 then cell.id = 193 elseif cell.id == 193 then cell.id = 192
	elseif cell.id == 245 then cell.id = 246 elseif cell.id == 246 then cell.id = 245
	elseif cell.id == 254 then cell.id = 255 elseif cell.id == 255 then cell.id = 254
	elseif cell.id == 258 then cell.id = 259 elseif cell.id == 259 then cell.id = 258
	elseif cell.id == 260 then cell.id = 261 elseif cell.id == 261 then cell.id = 260
	elseif cell.id == 264 then cell.id = 265 elseif cell.id == 265 then cell.id = 264
	elseif cell.id == 306 then cell.id = 307 elseif cell.id == 307 then cell.id = 306
	end
	--right facing cells
	local id = cell.id
	if id == 6 or id == 8
	or id == 2 or id == 14 or id == 17 or id == 28 or id == 58 or id == 59 or id == 60 or id == 61 or id == 72 or id == 73 or id == 74
	or id == 75 or id == 76 or id == 77 or id == 78 or id == 3 or id == 26 or id == 27 or id == 110 or id == 111 or id == 40 or id == 44 
	or id == 55 or id == 113 or id == 45 or id == 32 or id == 33 or id == 34 or id == 35 or id == 36 or id == 37 or id == 93 or id == 94 
	or id == 83 or id == 95 or id == 96 or id == 86 or id == 48 or id == 49 or id == 97 or id == 98 or id == 99 or id == 106 or id == 100 
	or id == 101 or id == 102 or id == 42 or id == 114 or id == 115 or id == 146 or id == 147 or id == 156 or id == 157 or id == 158 
	or id == 160 or id == 161 or id == 166 or id == 167 or id == 168 or id == 169 or id == 170 or id == 171 or id == 172 or id == 173 
	or id == 174 or id == 175 or id == 177 or id == 178 or id == 179 or id == 180 or id == 181 or id == 182 or id == 183 or id == 184 
	or id == 185 or id == 186 or id == 187 or id == 188 or id == 189 or id == 190 or id == 191 or id == 192 or id == 193 or id == 194 
	or id == 195 or id == 196 or id == 197 or id == 198 or id == 199 or id == 200 or id == 201 or id == 206 or id == 208 or id == 212 
	or id == 213 or id == 227 or id == 230 or id == 232 or id == 237 or id == 242 or id == 243 or id == 254 or id == 255 or id == 256 
	or id == 257 or id == 258 or id == 259 or id == 260 or id == 261 or id == 262 or id == 263 or id == 264 or id == 265 or id == 268
	or id == 269 or id == 270 or id == 271 or id == 272 or id == 273 or id == 274 or id == 275 or id == 276 or id == 277 or id == 278
	or id == 279 or id == 280 or id == 281 or id == 282 or id == 283 or id == 284 or id == 300 or id == 301 or id == 302 or id == 304
	or id == 305 or id == 311 then
		if rot == 0 or rot == 2 then
			cell.rot = (-cell.rot+2)%4
		else
			cell.rot = (-cell.rot)%4
		end
	--up-right facing cells
	elseif id == 7 or id == 23 or id == 46 or id == 107 or id == 140 or id == 148 or id == 155 or id == 209 or id == 228 or id == 238 or id == 268 then
		if (rot == 0 or rot == 2) and (cell.rot == 0 or cell.rot == 2) or (rot == 1 or rot == 3) and (cell.rot == 1 or cell.rot == 3) then
			cell.rot = (cell.rot - 1)%4
		else
			cell.rot = (cell.rot + 1)%4
		end
	--down-right facing cells
	elseif id == 57 or id == 16 or id == 31 or id == 91 or id == 92 then
		if (rot == 0 or rot == 2) and (cell.rot == 0 or cell.rot == 2) or (rot == 1 or rot == 3) and (cell.rot == 1 or cell.rot == 3) then
			cell.rot = (cell.rot + 1)%4
		else
			cell.rot = (cell.rot - 1)%4
		end
	end
end

function FlipCell(x,y,rot,dir)
	local cell = GetCell(x,y)
	if cell.locked then return end
	if cell.id == 105 and updatekey ~= cell.updatekey then
		cell.updatekey = updatekey
		local neighbors = GetNeighbors(x,y)
		for k,v in pairs(neighbors) do
			FlipCell(v[1],v[2],rot,k)
		end
	elseif not IsUnbreakable(cell,dir,x,y,{forcetype="flip",lastcell=getempty()}) and not IsNonexistant(cell,dir,x,y) then
		FlipCellRaw(cell,rot)
		SetChunk(x,y,cell)
		Play(rotatesound)
	end
end

function FreezeCell(x,y,dir,large)
	local cell = GetCell(x,y)
	if IsNonexistant(cell,dir,x,y) or IsUnbreakable(cell,dir,x,y,{forcetype="freeze"}) or cell.thawed then return end
	cell.updated = true
	cell.frozen = true
	if cell.id == 105 and updatekey ~= cell.updatekey then
		cell.updatekey = updatekey
		if large then
			local neighbors = GetSurrounding(x,y)
			for k,v in pairs(neighbors) do
				FreezeCell(v[1],v[2],k,true)
			end
		else
			local neighbors = GetNeighbors(x,y)
			for k,v in pairs(neighbors) do
				FreezeCell(v[1],v[2],k)
			end
		end
	end
end

function ThawCell(x,y,dir)
	local cell = GetCell(x,y)
	if IsNonexistant(cell,dir,x,y) then return end
	cell.thawed = true
	if cell.id == 105 and updatekey ~= cell.updatekey then
		cell.updatekey = updatekey
		local neighbors = GetNeighbors(x,y)
		for k,v in pairs(neighbors) do
			ThawCell(v[1],v[2],k)
		end
	end
end

function ProtectCell(x,y,dir,size)
	local cell = GetCell(x,y)
	if IsNonexistant(cell,dir,x,y) then return end
	cell.protected = true
	if cell.id == 105 and updatekey ~= cell.updatekey then
		cell.updatekey = updatekey
		if size == 1 then
			for cx=x-2,x+2 do
				for cy=y-2,y+2 do
					ProtectCell(cx,cy,0,1)
				end
			end
		elseif size == -1 then
			local neighbors = GetNeighbors(x,y)
			for k,v in pairs(neighbors) do
				ProtectCell(v[1],v[2],k,-1)
			end
		else
			local neighbors = GetSurrounding(x,y)
			for k,v in pairs(neighbors) do
				ProtectCell(v[1],v[2],k,size)
			end
		end
	end
end

function LockCell(x,y,dir)
	local cell = GetCell(x,y)
	if IsNonexistant(cell,dir,x,y) then return end
	cell.locked = true
	if cell.id == 105 and updatekey ~= cell.updatekey then
		cell.updatekey = updatekey
		local neighbors = GetNeighbors(x,y)
		for k,v in pairs(neighbors) do
			LockCell(v[1],v[2],k)
		end
	end
end

function ClampCell(x,y,dir)
	local cell = GetCell(x,y)
	if IsNonexistant(cell,dir,x,y) then return end
	cell.clamped = true
	if cell.id == 105 and updatekey ~= cell.updatekey then
		cell.updatekey = updatekey
		local neighbors = GetNeighbors(x,y)
		for k,v in pairs(neighbors) do
			ClampCell(v[1],v[2],k)
		end
	end
end

function LatchCell(x,y,dir)
	local cell = GetCell(x,y)
	if IsNonexistant(cell,dir,x,y) then return end
	cell.latched = true
	if cell.id == 105 and updatekey ~= cell.updatekey then
		cell.updatekey = updatekey
		local neighbors = GetNeighbors(x,y)
		for k,v in pairs(neighbors) do
			LatchCell(v[1],v[2],k)
		end
	end
end

function SealCell(x,y,dir)
	local cell = GetCell(x,y)
	if IsNonexistant(cell,dir,x,y) then return end
	cell.sealed = true
	if cell.id == 105 and updatekey ~= cell.updatekey then
		cell.updatekey = updatekey
		local neighbors = GetNeighbors(x,y)
		for k,v in pairs(neighbors) do
			SealCell(v[1],v[2],k)
		end
	end
end

function BoltCell(x,y,dir)
	local cell = GetCell(x,y)
	if IsNonexistant(cell,dir,x,y) then return end
	cell.bolted = true
	if cell.id == 105 and updatekey ~= cell.updatekey then
		cell.updatekey = updatekey
		local neighbors = GetNeighbors(x,y)
		for k,v in pairs(neighbors) do
			BoltCell(v[1],v[2],k)
		end
	end
end

function ReinforceCell(x,y,dir)
	local cell = GetCell(x,y)
	if IsNonexistant(cell,dir,x,y) then return end
	cell.reinforced = true
	if cell.id == 105 and updatekey ~= cell.updatekey then
		cell.updatekey = updatekey
		local neighbors = GetNeighbors(x,y)
		for k,v in pairs(neighbors) do
			ReinforceCell(v[1],v[2],k)
		end
	end
end

function GravitizeCell(x,y,dir,gdir)
	local cell = GetCell(x,y)
	if IsNonexistant(cell,dir,x,y) or IsUnbreakable(cell,dir,x,y,{forcetype="gravitize"}) then return end
	if cell.id == 105 and updatekey ~= cell.updatekey then
		cell.updatekey = updatekey
		local neighbors = GetNeighbors(x,y)
		for k,v in pairs(neighbors) do
			GravitizeCell(v[1],v[2],dir,gdir)
		end
	elseif cell.id ~= 232 and cell.id ~= 266 then
		cell.vars.gravdir = gdir
		SetChunkId(x,y,"gravity")
	end
end

function StickCell(x,y,dir,gdir)
	local cell = GetCell(x,y)
	if IsNonexistant(cell,dir,x,y) or IsUnbreakable(cell,dir,x,y,{forcetype="stick"}) then return end
	cell.sticky = true
	if cell.id == 105 and updatekey ~= cell.updatekey then
		cell.updatekey = updatekey
		local neighbors = GetNeighbors(x,y)
		for k,v in pairs(neighbors) do
			StickCell(v[1],v[2],dir)
		end
	end
end

function DoQuantumEnemy(cell,vars)
	RunOn(function(c) return c.vars[1] == cell.vars[1] end,
	function(x,y,c)
		if vars.undocells then vars.undocells[x+y*width] = vars.undocells[x+y*width] or c end
		SetCell(x,y,getempty())
		GetCell(x,y).eatencells = {c}
		if fancy then quantumparticles:setPosition(x*20-10,y*20-10) quantumparticles:emit(50) end
	end,
	"rightup",
	299)
end

function HandleNudge(cell,dir,x,y,vars)
	local id = cell.id
	local rot = cell.rot
	local side = ToSide(rot,dir)
	if type(ModStuff.custompush[cell.id]) == "function" then
		ModStuff.custompush[cell.id](cell, dir, x, y, vars, side, 1, "nudge")
	end
	if vars.active == "replace" then
		if id == 223 then
			vars.lastcell.vars.coins = (vars.lastcell.vars.coins or 0)+1
			coinparticles:setPosition(x*20-10,y*20-10)
			if fancy then coinparticles:emit(25) end
			Play(coinsound)
		end
	elseif vars.active == "destroy" then
		if (vars.lastcell.id == 160 or vars.lastcell.id == 288 or vars.lastcell.id == 293 or vars.lastcell.id == 294 or vars.lastcell.id == 295 or vars.lastcell.id == 296 or vars.lastcell.id == 298) then
			if vars.undocells then vars.undocells[x+y*width] = vars.undocells[x+y*width] or cell end
			if id == 24 then
				cell.id = 13
			elseif id == 164 and rot > 0 then
				cell.rot = cell.rot - 1
			elseif id == 299 then
				DoQuantumEnemy(cell,vars)
			elseif id ~= 244 then
				SetCell(x,y,getempty())
			end
			if fancy then enemyparticles:setPosition(x*20-10,y*20-10) enemyparticles:emit(50) end
			Play(destroysound)
		elseif vars.lastcell.id == 219 then
			if vars.undocells then vars.undocells[x+y*width] = vars.undocells[x+y*width] or cell end
			SetCell(x,y,vars.lastcell)
			if fancy then stallerparticles:setPosition(x*20-10,y*20-10) stallerparticles:emit(50) end
			Play(destroysound)
		elseif vars.lastcell.id == 220 then
			if vars.undocells then vars.undocells[x+y*width] = vars.undocells[x+y*width] or cell end
			SetCell(x,y,getempty())
			if fancy then stallerparticles:setPosition(x*20-10,y*20-10) stallerparticles:emit(50) end
			Play(destroysound)
		elseif (id == 48 or id == 99) and side == 2 and cell.supdatekey ~= supdatekey then
			cell.supdatekey = supdatekey
			local cx,cy,cdir,lastcell = NextCell(x,y,(dir-1)%4,table.copy(vars.lastcell))
			if cx then
				if id == 48 then lastcell.rot = (lastcell.rot - 1)%4 end
				NudgeCellTo(lastcell,cx,cy,cdir,table.copy(vars))
			end
			local cx,cy,cdir,lastcell = NextCell(x,y,(dir+1)%4,table.copy(vars.lastcell))
			if cx then
				if id == 48 then lastcell.rot = (lastcell.rot + 1)%4 end
				NudgeCellTo(lastcell,cx,cy,cdir,table.copy(vars))
			end
			supdatekey = supdatekey + 1
		elseif (id == 49 or id == 100) and side == 2 and cell.updatekey ~= updatekey then
			cell.updatekey = updatekey
			local cx,cy,cdir,lastcell = NextCell(x,y,dir,table.copy(vars.lastcell))
			if cx then
				NudgeCellTo(lastcell,cx,cy,cdir,table.copy(vars))
			end
			local cx,cy,cdir,lastcell = NextCell(x,y,(dir-1)%4,table.copy(vars.lastcell))
			if cx then
				if id == 49 then lastcell.rot = (lastcell.rot - 1)%4 end
				NudgeCellTo(lastcell,cx,cy,cdir,table.copy(vars))
			end
			local cx,cy,cdir,lastcell = NextCell(x,y,(dir+1)%4,table.copy(vars.lastcell))
			if cx then
				if id == 49 then lastcell.rot = (lastcell.rot + 1)%4 end
				NudgeCellTo(lastcell,cx,cy,cdir,table.copy(vars))
			end
			supdatekey = supdatekey + 1
		elseif (id == 97 or id == 101) and side == 2 and cell.updatekey ~= updatekey then
			cell.updatekey = updatekey
			local cx,cy,cdir,lastcell = NextCell(x,y,dir,table.copy(vars.lastcell))
			if cx then
				NudgeCellTo(lastcell,cx,cy,cdir,table.copy(vars))
			end
			local cx,cy,cdir,lastcell = NextCell(x,y,(dir+1)%4,table.copy(vars.lastcell))
			if cx then
				if id == 97 then lastcell.rot = (lastcell.rot + 1)%4 end
				NudgeCellTo(lastcell,cx,cy,cdir,table.copy(vars))
			end
			supdatekey = supdatekey + 1
		elseif (id == 98 or id == 102) and side == 2 and cell.updatekey ~= updatekey then
			cell.updatekey = updatekey
			local cx,cy,cdir,lastcell = NextCell(x,y,dir,table.copy(vars.lastcell))
			if cx then
				NudgeCellTo(lastcell,cx,cy,cdir,table.copy(vars))
			end
			local cx,cy,cdir,lastcell = NextCell(x,y,(dir-1)%4,table.copy(vars.lastcell))
			if cx then
				if id == 98 then lastcell.rot = (lastcell.rot - 1)%4 end
				NudgeCellTo(lastcell,cx,cy,cdir,table.copy(vars))
			end
			supdatekey = supdatekey + 1
		elseif id == 13 or id == 160 or id == 288 or id == 293 or id == 294 or id == 295 or id == 296 or id == 298 then
			if vars.undocells then vars.undocells[x+y*width] = vars.undocells[x+y*width] or table.copy(cell) end
			cell.eatencells = {table.copy(cell),vars.lastcell}
			cell.id = 0
			if fancy then enemyparticles:setPosition(x*20-10,y*20-10) enemyparticles:emit(50) end
			Play(destroysound)
		elseif id == 154 and vars.lastcell.id == 153 then
			if vars.undocells then vars.undocells[x+y*width] = vars.undocells[x+y*width] or table.copy(cell) end
			cell.eatencells = {table.copy(cell),vars.lastcell}
			cell.id = 0
			if fancy then sparkleparticles:setPosition(x*20-10,y*20-10) sparkleparticles:emit(50) end
			Play(unlocksound)
			Play(destroysound)
		elseif id == 24 then
			if vars.undocells then vars.undocells[x+y*width] = vars.undocells[x+y*width] or table.copy(cell) end
			cell.eatencells = {table.copy(cell),vars.lastcell}
			cell.id = 13
			if fancy then enemyparticles:setPosition(x*20-10,y*20-10) enemyparticles:emit(50) end
			Play(destroysound)
		elseif id == 164 then
			if vars.undocells then vars.undocells[x+y*width] = vars.undocells[x+y*width] or table.copy(cell) end
			cell.eatencells = {table.copy(cell),vars.lastcell}
			cell.rot = cell.rot - 1
			if cell.rot == -1  then cell.id = 0 end
			if fancy then swivelparticles:setPosition(x*20-10,y*20-10) swivelparticles:emit(50) end
			Play(destroysound)
		elseif id == 244 then
			if fancy then enemyparticles:setPosition(x*20-10,y*20-10) enemyparticles:emit(50) end
			Play(destroysound)
		elseif id == 299 then
			DoQuantumEnemy(cell,vars)
			table.insert(GetCell(x,y).eatencells,vars.lastcell)
			Play(destroysound)
		elseif id == 165 or id == 175 and (cell.updatekey == updatekey or not cell.vars[1]) then
			cell.updatekey = updatekey
			if cell.vars[1] then
				local cx,cy = x,y
				if dir == 0 then cx = x+1 elseif dir == 2 then cx = x-1 end
				if dir == 1 then cy = y+1 elseif dir == 3 then cy = y-1 end
				if cell.supdatekey ~= supdatekey or cell.scrosses ~= 5 then
					cell.scrosses = (cell.supdatekey == supdatekey and cell.scrosses or 0) + 1
					cell.supdatekey = supdatekey
					PushCell(cx,cy,dir,{force=1,replacecell={
					id=cell.vars[1],rot=cell.vars[2],lastvars={x,y,cell.vars[2]},updated=true,vars = DefaultVars(cell.vars[1])}})
				end
				cell.vars = {}
				supdatekey = supdatekey + 1
			end
			if not IsNonexistant(vars.lastcell,dir,x,y) then
				cell.vars[1] = vars.lastcell.id
				cell.vars[2] = vars.lastcell.rot
			end
		elseif id == 198 and side == 2 then
			if cell.vars[1] then
				local cx,cy = x,y
				if dir == 0 then cx = x+1 elseif dir == 2 then cx = x-1 end
				if dir == 1 then cy = y+1 elseif dir == 3 then cy = y-1 end
				local rc = table.copy(vars.lastcell)
				rc.id = cell.vars[1]
				rc.rot = cell.vars[2]
				PushCell(cx,cy,dir,{force=1,replacecell=rc})
			elseif not IsNonexistant(vars.lastcell,dir,x,y) then
				cell.vars[1] = vars.lastcell.id
				cell.vars[2] = vars.lastcell.rot
			end
		elseif id == 233 and (side == 1 or side == 3) then
			cell.vars[1] = vars.lastcell.id
		elseif (id == 12 or id == 205 or (id == 225 or id == 226) and (side == 0 or side == 2) or id == 300 and side == 0 or id == 44 and side == 0 or id == 155 and (side == 0 or side == 3) or id == 250 and (side == 0 or side == 2) or id == 251) and not IsNonexistant(vars.lastcell,dir,x,y,vars) then
			Play(destroysound)
		elseif id == 51 then
			local neighbors = GetNeighbors(x,y)
			for k,v in pairs(neighbors) do
				local c = GetCell(v[1],v[2])
				if not IsUnbreakable(c,k,v[1],v[2],{forcetype="destroy",lastcell=cell}) then
					SetCell(v[1],v[2],getempty())
					GetCell(v[1],v[2]).eatencells = {c}
				end
			end
			Play(destroysound)
		elseif id == 141 then
			local neighbors = GetSurrounding(x,y)
			for k,v in pairs(neighbors) do
				local c = GetCell(v[1],v[2])
				if not IsUnbreakable(c,k,v[1],v[2],{forcetype="destroy",lastcell=cell}) then
					SetCell(v[1],v[2],getempty())
					GetCell(v[1],v[2]).eatencells = {c}
				end
			end
			Play(destroysound)
		elseif id == 176 then
			SetCell(vars.lastx,vars.lasty,table.copy(cell))
			Play(destroysound)
			Play(infectsound)
		elseif id == 32 or id == 33 or id == 34 or id == 35 or id == 36 or id == 37 or id == 194 or id == 195 or id == 196 or id == 197 then
			Play(destroysound)
			if side == 3 then cell.inl = true
			elseif side == 1 then cell.inr = true end
		elseif id == 186 or id == 187 or id == 188 or id == 189 or id == 190 or id == 191 or id == 192 or id == 193 then
			if not cell.output then
				cell.output = vars.lastcell
				if side == 1 and id < 190 then cell.output.rot = (cell.output.rot+1)%4
				elseif side == 3 and id < 190 then cell.output.rot = (cell.output.rot-1)%4 end
			end
		end
	else
		if id == 126 and not IsUnbreakable(vars.lastcell,(dir-2)%4,vars.lastx,vars.lasty,{forcetype="infect",lastcell=vars.lastcell,lastx=vars.lastx,lasty=vars.lasty}) and not IsNonexistant(vars.lastcell,(dir-2)%4,vars.lastx,vars.lasty) then
			if vars.undocells and vars.undocells[vars.lastx+vars.lasty*width] ~= vars.lastcell then
				vars.undocells[vars.lastx+vars.lasty*width] = CopyCell(x,y)
			else
				SetCell(vars.lastx,vars.lasty,CopyCell(x,y))
			end
			Play(infectsound)
		elseif id == 150 and not IsUnbreakable(vars.lastcell,(dir-2)%4,vars.lastx,vars.lasty,{forcetype="rotate",lastcell=vars.lastcell,lastx=vars.lastx,lasty=vars.lasty}) and not IsNonexistant(vars.lastcell,(dir-2)%4,vars.lastx,vars.lasty) then
			if vars.undocells and vars.undocells[vars.lastx+vars.lasty*width] ~= vars.lastcell then
				vars.undocells[vars.lastx+vars.lasty*width].rot = (vars.undocells[vars.lastx+vars.lasty*width].rot+1)%4
			else
				vars.lastcell.rot = (vars.lastcell.rot+1)%4
			end
			Play(rotatesound)
		elseif id == 151 and not IsUnbreakable(vars.lastcell,(dir-2)%4,vars.lastx,vars.lasty,{forcetype="rotate",lastcell=vars.lastcell,lastx=vars.lastx,lasty=vars.lasty}) and not IsNonexistant(vars.lastcell,(dir-2)%4,vars.lastx,vars.lasty) then
			if vars.undocells and vars.undocells[vars.lastx+vars.lasty*width] ~= vars.lastcell then
				vars.undocells[vars.lastx+vars.lasty*width].rot = (vars.undocells[vars.lastx+vars.lasty*width].rot-1)%4
			else
				vars.lastcell.rot = (vars.lastcell.rot-1)%4
			end
			Play(rotatesound)
		elseif id == 152 and not IsUnbreakable(vars.lastcell,(dir-2)%4,vars.lastx,vars.lasty,{forcetype="rotate",lastcell=vars.lastcell,lastx=vars.lastx,lasty=vars.lasty}) and not IsNonexistant(vars.lastcell,(dir-2)%4,vars.lastx,vars.lasty) then
			if vars.undocells and vars.undocells[vars.lastx+vars.lasty*width] ~= vars.lastcell then
				vars.undocells[vars.lastx+vars.lasty*width].rot = (vars.undocells[vars.lastx+vars.lasty*width].rot+2)%4
			else
				vars.lastcell.rot = (vars.lastcell.rot+2)%4
			end
			Play(rotatesound)
		elseif id == 162 then
			SetCell(x,y,getempty())
			if vars.undocells then
				vars.undocells[x+y*width] = getempty()
			end
			if fancy then stallerparticles:setPosition(x*20-10,y*20-10) stallerparticles:emit(50) end
			Play(destroysound)
		elseif id == 163 and not IsUnbreakable(vars.lastcell,(dir-2)%4,vars.lastx,vars.lasty,{forcetype="destroy",lastcell=vars.lastcell,lastx=vars.lastx,lasty=vars.lasty}) and not IsNonexistant(vars.lastcell,(dir-2)%4,vars.lastx,vars.lasty) then
			SetCell(x,y,getempty())
			SetCell(vars.lastx,vars.lasty,getempty())
			if vars.undocells then
				vars.undocells[x+y*width] = getempty()
				vars.undocells[vars.lastx+vars.lasty*width] = getempty()
			end
			if fancy then bulkparticles:setPosition(x*20-10,y*20-10) bulkparticles:emit(50) end
			Play(destroysound)
		elseif id == 229 and side == 2 then
			cx,cy = x,y
			if dir == 0 then cx = x+1 elseif dir == 2 then cx = x-1 end
			if dir == 1 then cy = y+1 elseif dir == 3 then cy = y-1 end
			local gen = table.copy(vars.lastcell)
			gen.lastvars = {x,y,gen.rot}
			PushCell(cx,cy,dir,{replacecell=gen,force=1,noupdate=true})
			vars.optimizegen = false
		end
	end
end

function HandlePush(force,cell,dir,x,y,vars)
	local id = cell.id
	local rot = cell.rot
	local side = ToSide(rot,dir)
	local gfactor = cell.vars.gravdir == dir and 1 or cell.vars.gravdir == (dir+2)%4 and -1 or 0
	if type(ModStuff.custompush[cell.id]) == "function" then
		return ModStuff.custompush[cell.id](cell, dir, x, y, vars, side, force + gfactor, "push")
	end
	if cell.sticky and not vars.checkonly then
		if not vars.sticking then stickkey = stickkey + 1 end
		vars.sticking = true
		cell.stickkey = stickkey
		if (dir == 0 or dir == 2) then
			local c2 = GetCell(x,y-1)
			if c2.sticky and c2.stickkey ~= stickkey then
				local vars1 = table.copy(vars)
				vars1.force = force
				vars1.replacecell = getempty()
				if PushCell(x,y-1,dir,vars1) then
					table.merge(vars.undocells,vars1.undocells)
				else
					return 0
				end
			end
			local c2 = GetCell(x,y+1)
			if c2.sticky and c2.stickkey ~= stickkey then
				local vars1 = table.copy(vars)
				vars1.force = force
				vars1.replacecell = getempty()
				if PushCell(x,y+1,dir,vars1) then
					table.merge(vars.undocells,vars1.undocells)
				else
					return 0
				end
			end
			if GetCell(x,y) ~= cell then
				vars.ended = true
			end
		elseif (dir == 1 or dir == 3) then
			local c2 = GetCell(x+1,y)
			if c2.sticky and c2.stickkey ~= stickkey then
				local vars1 = table.copy(vars)
				vars1.force = force
				vars1.replacecell = getempty()
				if PushCell(x+1,y,dir,vars1) then
					table.merge(vars.undocells,vars1.undocells)
				else
					return 0
				end
			end
			local c2 = GetCell(x-1,y)
			if c2.sticky and c2.stickkey ~= stickkey then
				local vars1 = table.copy(vars)
				vars1.force = force
				vars1.replacecell = getempty()
				if PushCell(x-1,y,dir,vars1) then
					table.merge(vars.undocells,vars1.undocells)
				else
					return 0
				end
			end
			if GetCell(x,y) ~= cell then
				vars.ended = true
			end
		end
	end
	if (vars.lastcell.id == 13 or vars.lastcell.id == 160 or vars.lastcell.id == 288 or vars.lastcell.id == 293 or vars.lastcell.id == 294 or vars.lastcell.id == 295 or vars.lastcell.id == 296 or vars.lastcell.id == 298) and vars.destroying and not IsUnbreakable(cell,x,y,dir,{forcetype="destroy",lastcell=vars.lastcell}) then
		vars.undocells[x+y*width] = vars.undocells[x+y*width] or table.copy(cell)
		if id == 24 then
			cell.id = 13
		elseif id == 164 and rot > 0 then
			cell.rot = cell.rot - 1
		elseif cell.id == 299 then
			DoQuantumEnemy(cell,vars)
		elseif id ~= 244 then
			SetCell(x,y,getempty())
		end
		if fancy then enemyparticles:setPosition(x*20-10,y*20-10) enemyparticles:emit(50) GetCell(x,y).eatencells = {table.copy(cell)} end
		Play(destroysound)
		return force
	elseif vars.lastcell.id == 24 and vars.destroying and not IsUnbreakable(cell,x,y,dir,{forcetype="destroy",lastcell=vars.lastcell}) then
		vars.undocells[x+y*width] = vars.undocells[x+y*width] or table.copy(cell)
		if id == 164 and rot > 1 then
			cell.rot = cell.rot - 2
		elseif id == 24 or id == 244 or id == 164 and rot == 1 then
			SetCell(x,y,getempty())
		elseif cell.id == 299 then
			DoQuantumEnemy(cell,vars)
			vars.lastcell.id = 13
			SetCell(x,y,vars.lastcell)
		else
			vars.lastcell.id = 13
			cell.id = 0
		end
		if fancy then GetCell(x,y).eatencells = {table.copy(cell)} end
		if fancy then enemyparticles:setPosition(x*20-10,y*20-10) enemyparticles:emit(50) end
		Play(destroysound)
		return force
	elseif vars.lastcell.id == 164 and vars.destroying and not IsUnbreakable(cell,x,y,dir,{forcetype="destroy",lastcell=vars.lastcell}) then
		vars.undocells[x+y*width] = vars.undocells[x+y*width] or table.copy(cell)
		if id == 13 then
			vars.lastcell.rot = vars.lastcell.rot - 1
			if vars.lastcell.rot == -1 then
				SetCell(x,y,getempty())
			else
				cell.id = 0
			end
		elseif id == 24 then
			vars.lastcell.rot = vars.lastcell.rot - 2
			if vars.lastcell.rot == -1 then
				SetCell(x,y,getempty())
			elseif vars.lastcell.rot == -2 then
				cell.id = 13
			else
				cell.id = 0
			end
		elseif id == 164 then
			if vars.lastcell.rot > rot then
				cell.id = 0
				vars.lastcell.rot = vars.lastcell.rot-rot-1
			elseif vars.lastcell.rot < cell.rot then
				cell.rot = cell.rot-vars.lastcell.rot-1
			else
				SetCell(x,y,getempty())
			end
		elseif cell.id == 299 then
			DoQuantumEnemy(cell,vars)
			vars.lastcell.rot = vars.lastcell.rot - 1
			if vars.lastcell.rot == -1 then
				SetCell(x,y,getempty())
			else
				SetCell(x,y,vars.lastcell)
			end
		elseif id ~= 244 then
			cell.id = 0
		else
			vars.lastcell.rot = vars.lastcell.rot - 1
			if vars.lastcell.rot == -1 then
				SetCell(x,y,getempty())
			end
		end
		if fancy then swivelparticles:setPosition(x*20-10,y*20-10) swivelparticles:emit(50) GetCell(x,y).eatencells = {table.copy(cell)} end
		Play(destroysound)
		return force
	elseif vars.lastcell.id == 244 and vars.destroying and not IsUnbreakable(cell,x,y,dir,{forcetype="destroy",lastcell=vars.lastcell}) then
		if id == 244 then
			SetCell(x,y,getempty())
		elseif cell.id == 299 then
			DoQuantumEnemy(cell,vars)
			SetCell(x,y,vars.lastcell)
		else
			cell.id = 0
		end
		if fancy then enemyparticles:setPosition(x*20-10,y*20-10) enemyparticles:emit(50) GetCell(x,y).eatencells = {table.copy(cell)} end
		Play(destroysound)
		return force
	elseif vars.lastcell.id == 299 and vars.destroying and not IsUnbreakable(cell,x,y,dir,{forcetype="destroy",lastcell=vars.lastcell}) then
		DoQuantumEnemy(vars.lastcell,vars)
		if id == 24 then
			cell.id = 13
		elseif id == 164 and rot > 0 then
			cell.rot = cell.rot - 1
		elseif cell.id == 299 then
			DoQuantumEnemy(cell,vars)
		elseif id ~= 244 then
			SetCell(x,y,getempty())
		end
		Play(destroysound)
		return force
	elseif vars.lastcell.id == 219 and vars.destroying and not IsUnbreakable(cell,x,y,dir,{forcetype="destroy",lastcell=vars.lastcell}) then
		vars.undocells[x+y*width] = vars.undocells[x+y*width] or table.copy(cell)
		SetCell(x,y,vars.lastcell)
		if fancy then stallerparticles:setPosition(x*20-10,y*20-10) stallerparticles:emit(50) GetCell(x,y).eatencells = {table.copy(cell)} end
		Play(destroysound)
		return force
	elseif vars.lastcell.id == 220 and vars.destroying and not IsUnbreakable(cell,x,y,dir,{forcetype="destroy",lastcell=vars.lastcell}) then
		vars.undocells[x+y*width] = vars.undocells[x+y*width] or table.copy(cell)
		SetCell(x,y,getempty())
		if fancy then stallerparticles:setPosition(x*20-10,y*20-10) stallerparticles:emit(50) GetCell(x,y).eatencells = {table.copy(cell)} end
		Play(destroysound)
		return force
	else
		if cell.clamped then
			return 0
		elseif id == 42 and side == 0 or id == 22 then
			return force-1+gfactor
		elseif id == 42 and side == 2 or id == 104 then
			return force+1+gfactor
		elseif id == 142 then
			return force == 1 and 1+gfactor or 0
		elseif id == 143 then
			return force == rot+1 and rot+1+gfactor or 0
		elseif id == 144 then
			return 1+gfactor
		elseif (id == 13 or id == 160 or id == 288 or id == 293 or id == 294 or id == 295 or id == 296 or id == 298) and vars.destroying and not IsNonexistant(vars.lastcell,x,y,(dir+2)) then
			vars.undocells[x+y*width] = vars.undocells[x+y*width] or table.copy(cell)
			SetCell(x,y,getempty())
			if fancy then enemyparticles:setPosition(x*20-10,y*20-10) enemyparticles:emit(50) end
			Play(destroysound)
			return force
		elseif id == 299 and vars.destroying and not IsNonexistant(vars.lastcell,x,y,(dir+2)) then
			DoQuantumEnemy(cell,vars)
			Play(destroysound)
			return force
		elseif (id == 2 or id == 213 and (side == 0 or side == 2)) and not cell.frozen then
			if side == 2 then
				cell.updated = cell.updated or not vars.noupdate
				return force+1+gfactor
			elseif side == 0 then
				cell.updated = cell.updated or not vars.noupdate
				return force-1+gfactor
			end
		elseif (id == 28 or id == 72 or id == 74 or id == 59 or id == 60 or id == 76 or id == 78
		or id == 269 or id == 271 or id == 273 or id == 275 or id == 277 or id == 279 or id == 281 or id == 283
		or id == 206 or id == 303 or id == 304) and not cell.frozen or id == 311 then
			if side == 2 then
				vars.undocells[x+y*width] = vars.undocells[x+y*width] or table.copy(cell)	--dont update if movement fails
				cell.updated = cell.updated or not vars.noupdate
				return force+1+gfactor
			elseif side == 0 then
				return force-1+gfactor
			end
		elseif id == 14 or id == 58 or id == 61 or id == 71 or id == 73 or id == 75 or id == 77 or id == 114
		or id == 115 or id == 270 or id == 272 or id == 274 or id == 276 or id == 278 or id == 280 or id == 282
		or id == 160 or id == 161 or id == 175 and cell.updatekey ~= updatekey and cell.vars[1] or id == 178
		or id == 179 or id == 180 or id == 181 or id == 182 or id == 183 or id == 184 or id == 185 or id == 305 then
			if side == 2 then
				vars.undocells[x+y*width] = vars.undocells[x+y*width] or table.copy(cell)
				cell.updated = cell.updated or not vars.noupdate
			end
		elseif id == 284 and not cell.frozen then
			if side == 2 then
				return math.huge
			elseif side == 0 then
				return 0
			end
		elseif id == 103 then
			return math.max(force-rot+gfactor,0)
		elseif id == 21 or id == 222 then
			return force == 1 and 0 or force
		elseif id == 24 and vars.destroying and not IsNonexistant(vars.lastcell,x,y,(dir+2)) then
			vars.undocells[x+y*width] = vars.undocells[x+y*width] or table.copy(cell)
			SetCell(x,y,{id=13,rot=0,lastvars={x,y,0},vars={}})
			if fancy then enemyparticles:setPosition(x*20-10,y*20-10) enemyparticles:emit(50) end
			Play(destroysound)
			return force
		elseif id == 164 and vars.destroying and not IsNonexistant(vars.lastcell,x,y,(dir+2)) then
			vars.undocells[x+y*width] = vars.undocells[x+y*width] or table.copy(cell)
			cell.rot = cell.rot - 1
			if cell.rot == -1 then SetCell(x,y,getempty()) end
			if fancy then swivelparticles:setPosition(x*20-10,y*20-10) swivelparticles:emit(50) end
			Play(destroysound)
			return force
		elseif id == 244 and vars.destroying and not IsNonexistant(vars.lastcell,x,y,(dir+2)) then
			if fancy then enemyparticles:setPosition(x*20-10,y*20-10) enemyparticles:emit(50) end
			Play(destroysound)
			return force
		elseif id == 163 and vars.destroying and not IsNonexistant(vars.lastcell,x,y,(dir+2)) then
			vars.undocells[x+y*width] = getempty()
			if vars.lastcell.id == 24 then vars.undocells[vars.lastx+vars.lasty*width].id = 13
			elseif vars.lastcell.id == 164 and vars.lastcell.rot > 0 then vars.undocells[vars.lastx+vars.lasty*width].rot = vars.lastcell.rot-1
			elseif vars.undocells[vars.lastx+vars.lasty*width] then vars.undocells[vars.lastx+vars.lasty*width] = getempty() end
			if fancy then bulkparticles:setPosition(x*20-10,y*20-10) bulkparticles:emit(50) end
			Play(destroysound)
			vars.optimizegen = false
			return 0
		elseif id == 165 or id == 175 and (cell.updatekey == updatekey or not cell.vars[1]) then
			cell.updatekey = updatekey
			if cell.vars[1] then
				local cx,cy = x,y
				if dir == 0 then cx = x+1 elseif dir == 2 then cx = x-1 end
				if dir == 1 then cy = y+1 elseif dir == 3 then cy = y-1 end
				if cell.supdatekey ~= supdatekey or cell.scrosses ~= 5 then
					cell.scrosses = (cell.supdatekey == supdatekey and cell.scrosses or 0) + 1
					cell.supdatekey = supdatekey
					PushCell(cx,cy,dir,{force=1,replacecell={
					id=cell.vars[1],rot=cell.vars[2],lastvars={x,y,cell.vars[2]},updated=true,vars = DefaultVars(cell.vars[1])}})
				end
				cell.vars = {}
				supdatekey = supdatekey + 1
			end
			if not IsNonexistant(vars.lastcell,dir,x,y) then
				cell.vars[1] = vars.lastcell.id
				cell.vars[2] = vars.lastcell.rot
			end
		elseif id == 198 and side == 2 then
			if cell.vars[1] then
				local cx,cy = x,y
				if dir == 0 then cx = x+1 elseif dir == 2 then cx = x-1 end
				if dir == 1 then cy = y+1 elseif dir == 3 then cy = y-1 end
				local rc = table.copy(vars.lastcell)
				rc.id = cell.vars[1]
				rc.rot = cell.vars[2]
				PushCell(cx,cy,dir,{force=1,replacecell=rc})
			elseif not IsNonexistant(vars.lastcell,dir,x,y) then
				cell.vars[1] = vars.lastcell.id
				cell.vars[2] = vars.lastcell.rot
			end
		elseif id == 233 and (side == 1 or side == 3) then
			cell.vars[1] = vars.lastcell.id
		elseif id == 166 and (side == 1 or side == 3) then
			cell.vars = {}
		elseif id == 236 then
			local oldcell = table.copy(cell)
			if dir == 0 or dir == 2 then
				cell.vars[1] = dir == 0 and 1 or -1
			elseif dir == 1 or dir == 3 then
				cell.vars[2] = dir == 1 and 1 or -1
			end
			if dir == 0 and cell.vars[1] == 1 or dir == 2 and cell.vars[1] == -1 or dir == 1 and cell.vars[2] == 1 or dir == 3 and cell.vars[2] == -1 then
				vars.undocells[x+y*width] = vars.undocells[x+y*width] or oldcell
				return force+1
			elseif dir == 2 and cell.vars[1] == 1 or dir == 0 and cell.vars[1] == -1 or dir == 3 and cell.vars[2] == 1 or dir == 1 and cell.vars[2] == -1 then
				return force-1
			end
		elseif id == 207 and (side == 1 or side == 3) then
			local gvars = table.copy(vars)
			gvars.force = force
			GraspEmptyCell(x,y,dir,gvars)
			table.merge(vars.undocells,gvars.undocells)
		elseif id == 154 and vars.lastcell.id == 153 then
			vars.undocells[x+y*width] = vars.undocells[x+y*width] or table.copy(cell)
			SetCell(x,y,getempty())
			if fancy then sparkleparticles:setPosition(x*20-10,y*20-10) sparkleparticles:emit(50) end
			Play(unlocksound)
			Play(destroysound)
			return force
		elseif id == 162 then
			vars.undocells[x+y*width] = getempty()
			if fancy then stallerparticles:setPosition(x*20-10,y*20-10) stallerparticles:emit(50) end
			Play(destroysound)
			vars.optimizegen = false
			return 0
		elseif (id == 12 or id == 205 or (id == 225 or id == 226) and (side == 0 or side == 2) or id == 300 and side == 0 or id == 44 and side == 0 or id == 155 and (side == 0 or side == 3) or id == 250 and (side == 0 or side == 2) or id == 251) and not IsNonexistant(vars.lastcell,dir,x,y,vars) then
			Play(destroysound)
			return force
		elseif id == 51 and not IsNonexistant(vars.lastcell,dir,x,y,vars) then
			local neighbors = GetNeighbors(x,y)
			for k,v in pairs(neighbors) do
				local c = GetCell(v[1],v[2])
				if not IsUnbreakable(c,k,v[1],v[2],{forcetype="destroy",lastcell=cell}) then
					SetCell(v[1],v[2],getempty())
					GetCell(v[1],v[2]).eatencells = {c}
				end
			end
			Play(destroysound)
			return force
		elseif id == 141 and not IsNonexistant(vars.lastcell,dir,x,y,vars) then
			local neighbors = GetSurrounding(x,y)
			for k,v in pairs(neighbors) do
			local c = GetCell(v[1],v[2])
				if not IsUnbreakable(c,k,v[1],v[2],{forcetype="destroy",lastcell=cell}) then
					SetCell(v[1],v[2],getempty())
					GetCell(v[1],v[2]).eatencells = {c}
				end
			end
			Play(destroysound)
			return force
		elseif id == 176 and not IsNonexistant(vars.lastcell,dir,x,y,vars) then
			SetCell(vars.lastx,vars.lasty,table.copy(cell))
			Play(destroysound)
			Play(infectsound)
			return force
		elseif id == 47 and not IsUnbreakable(vars.lastcell,(dir-2)%4,vars.lastx,vars.lasty,{forcetype="infect",lastcell=vars.lastcell,lastx=vars.lastx,lasty=vars.lasty}) and not IsNonexistant(vars.lastcell,(dir-2)%4,vars.lastx,vars.lasty) then
			vars.lastcell.id = 47
			Play(infectsound)
		elseif (id == 231 or id == 249) and not cell.sticky and not vars.checkonly then
			if not vars.sticking then stickkey = stickkey + 1 end
			vars.sticking = true
			cell.stickkey = stickkey
			force = force + gfactor
			if (dir == 0 or dir == 2) and (id == 231 or cell.rot == 1 or cell.rot == 3) then
				local c2 = GetCell(x,y-1)
				if (c2.id == 231 or c2.id == 249 and (c2.rot == 1 or c2.rot == 3)) and c2.stickkey ~= stickkey then
					local vars1 = table.copy(vars)
					vars1.force = force
					vars1.replacecell = getempty()
					vars1.noupdate = true
					if PushCell(x,y-1,dir,vars1) then
						table.merge(vars.undocells,vars1.undocells)
					else
						return 0
					end
				end
				local c2 = GetCell(x,y+1)
				if (c2.id == 231 or c2.id == 249 and (c2.rot == 1 or c2.rot == 3)) and c2.stickkey ~= stickkey then
					local vars1 = table.copy(vars)
					vars1.force = force
					vars1.replacecell = getempty()
					vars1.noupdate = true
					if PushCell(x,y+1,dir,vars1) then
						table.merge(vars.undocells,vars1.undocells)
					else
						return 0
					end
				end
				if GetCell(x,y) ~= cell then
					vars.ended = true
				end
			elseif (dir == 1 or dir == 3) and (id == 231 or cell.rot == 0 or cell.rot == 2) then
				local c2 = GetCell(x+1,y)
				if (c2.id == 231 or c2.id == 249 and (c2.rot == 0 or c2.rot == 2)) and c2.stickkey ~= stickkey then
					local vars1 = table.copy(vars)
					vars1.force = force
					vars1.replacecell = getempty()
					vars1.noupdate = true
					if PushCell(x+1,y,dir,vars1) then
						table.merge(vars.undocells,vars1.undocells)
					else
						return 0
					end
				end
				local c2 = GetCell(x-1,y)
				if (c2.id == 231 or c2.id == 249 and (c2.rot == 0 or c2.rot == 2)) and c2.stickkey ~= stickkey then
					local vars1 = table.copy(vars)
					vars1.force = force
					vars1.replacecell = getempty()
					vars1.noupdate = true
					if PushCell(x-1,y,dir,vars1) then
						table.merge(vars.undocells,vars1.undocells)
					else
						return 0
					end
				end
				if GetCell(x,y) ~= cell then
					vars.ended = true
				end
			end
			return force
		elseif id == 126 and not IsUnbreakable(vars.lastcell,(dir-2)%4,vars.lastx,vars.lasty,{forcetype="infect",lastcell=vars.lastcell}) then
			if vars.undocells[vars.lastx+vars.lasty*width] then
				vars.undocells[vars.lastx+vars.lasty*width] = CopyCell(x,y)	--since this is a wall it'll undo the changes
				Play(infectsound)
			end
			vars.optimizegen = false
			return 0
		elseif id == 150 and not IsUnbreakable(vars.lastcell,(dir-2)%4,vars.lastx,vars.lasty,{forcetype="rotate",lastcell=vars.lastcell}) then
			if vars.undocells[vars.lastx+vars.lasty*width] then
				vars.undocells[vars.lastx+vars.lasty*width].rot = (vars.undocells[vars.lastx+vars.lasty*width].rot+1)%4
				Play(rotatesound)
			end
			vars.optimizegen = false
			return 0
		elseif id == 151 and not IsUnbreakable(vars.lastcell,(dir-2)%4,vars.lastx,vars.lasty,{forcetype="rotate",lastcell=vars.lastcell}) then
			if vars.undocells[vars.lastx+vars.lasty*width] then
				vars.undocells[vars.lastx+vars.lasty*width].rot = (vars.undocells[vars.lastx+vars.lasty*width].rot-1)%4
				Play(rotatesound)
				vars.optimizegen = false
			end
			vars.optimizegen = false
			return 0
		elseif id == 152 and not IsUnbreakable(vars.lastcell,(dir-2)%4,vars.lastx,vars.lasty,{forcetype="rotate",lastcell=vars.lastcell}) then
			if vars.undocells[vars.lastx+vars.lasty*width] then
				vars.undocells[vars.lastx+vars.lasty*width].rot = (vars.undocells[vars.lastx+vars.lasty*width].rot+2)%4
				Play(rotatesound)
			end
			vars.optimizegen = false
			return 0
		elseif id == 229 and side == 2 then
			cx,cy = x,y
			if dir == 0 then cx = x+1 elseif dir == 2 then cx = x-1 end
			if dir == 1 then cy = y+1 elseif dir == 3 then cy = y-1 end
			local gen = table.copy(vars.lastcell)
			gen.lastvars = {x,y,gen.rot}
			PushCell(cx,cy,dir,{replacecell=gen,force=1,noupdate=true})
			vars.optimizegen = false
			return 0
		elseif (id == 32 or id == 33 or id == 34 or id == 35 or id == 36 or id == 37 or id == 194 or id == 195 or id == 196 or id == 197) and not IsNonexistant(vars.lastcell,dir,x,y,vars) then
			Play(destroysound)
			if side == 3 then cell.inl = true
			elseif side == 1 then cell.inr = true
			else return 0 end
		elseif (id == 186 or id == 187 or id == 188 or id == 189 or id == 190 or id == 191 or id == 192 or id == 193) and IsDestroyer(cell,dir,x,y,vars) and not IsNonexistant(vars.lastcell,dir,x,y,vars) then
			if not cell.output then
				cell.output = vars.lastcell
				if side == 1 and id < 190 then cell.output.rot = (cell.output.rot+1)%4
				elseif side == 3 and id < 190 then cell.output.rot = (cell.output.rot-1)%4 end
			end
		elseif id == 223 then
			vars.lastcell.vars.coins = (vars.lastcell.vars.coins or 0)+1
			if fancy then coinparticles:setPosition(x*20-10,y*20-10) coinparticles:emit(25) end
			Play(coinsound)
		elseif (id == 48 or id == 99) and side == 2 and cell.supdatekey ~= supdatekey then
			cell.supdatekey = supdatekey
			local cx,cy,cdir,newcell = NextCell(x,y,(dir-1)%4,table.copy(vars.lastcell))
			newcell.rot = (newcell.rot-(id == 48 and 1 or 0))%4
			local newvars = table.copy(vars)
			newvars.force,newvars.replacecell,newvars.undocells = force,newcell,nil
			PushCell(cx,cy,cdir,newvars)
			local cx,cy,cdir,newcell = NextCell(x,y,(dir+1)%4,table.copy(vars.lastcell))
			newcell.rot = (newcell.rot+(id == 48 and 1 or 0))%4
			local newvars = table.copy(vars)
			newvars.force,newvars.replacecell,newvars.undocells = force,newcell,nil
			PushCell(cx,cy,cdir,newvars)
			supdatekey = supdatekey + 1
			return force
		elseif (id == 49 or id == 100) and side == 2 and cell.supdatekey ~= supdatekey then
			cell.supdatekey = supdatekey
			local cx,cy,cdir,newcell = NextCell(x,y,(dir)%4,table.copy(vars.lastcell))
			local newvars = table.copy(vars)
			newvars.force,newvars.replacecell,newvars.undocells = force,newcell,nil
			PushCell(cx,cy,cdir,newvars)
			local cx,cy,cdir,newcell = NextCell(x,y,(dir-1)%4,table.copy(vars.lastcell))
			newcell.rot = (newcell.rot-(id == 49 and 1 or 0))%4
			local newvars = table.copy(vars)
			newvars.force,newvars.replacecell,newvars.undocells = force,newcell,nil
			PushCell(cx,cy,cdir,newvars)
			local cx,cy,cdir,newcell = NextCell(x,y,(dir+1)%4,table.copy(vars.lastcell))
			newcell.rot = (newcell.rot+(id == 49 and 1 or 0))%4
			local newvars = table.copy(vars)
			newvars.force,newvars.replacecell,newvars.undocells = force,newcell,nil
			PushCell(cx,cy,cdir,newvars)
			supdatekey = supdatekey + 1
			return force
		elseif (id == 97 or id == 101) and side == 2 and cell.supdatekey ~= supdatekey then
			cell.supdatekey = supdatekey
			local cx,cy,cdir,newcell = NextCell(x,y,(dir)%4,table.copy(vars.lastcell))
			local newvars = table.copy(vars)
			newvars.force,newvars.replacecell,newvars.undocells = force,newcell,nil
			PushCell(cx,cy,cdir,newvars)
			local cx,cy,cdir,newcell = NextCell(x,y,(dir+1)%4,table.copy(vars.lastcell))
			newcell.rot = (newcell.rot+(id == 97 and 1 or 0))%4
			local newvars = table.copy(vars)
			newvars.force,newvars.replacecell,newvars.undocells = force,newcell,nil
			PushCell(cx,cy,cdir,newvars)
			supdatekey = supdatekey + 1
			return force
		elseif (id == 98 or id == 102) and side == 2 and cell.supdatekey ~= supdatekey then
			cell.supdatekey = supdatekey
			local cx,cy,cdir,newcell = NextCell(x,y,(dir)%4,table.copy(vars.lastcell))
			local newvars = table.copy(vars)
			newvars.force,newvars.replacecell,newvars.undocells = force,newcell,nil
			PushCell(cx,cy,cdir,newvars)
			local cx,cy,cdir,newcell = NextCell(x,y,(dir-1)%4,table.copy(vars.lastcell))
			newcell.rot = (newcell.rot-(id == 98 and 1 or 0))%4
			local newvars = table.copy(vars)
			newvars.force,newvars.replacecell,newvars.undocells = force,newcell,nil
			PushCell(cx,cy,cdir,newvars)
			supdatekey = supdatekey + 1
			return force
		elseif IsUnbreakable(cell,dir,x,y,vars) and not IsDestroyer(cell,dir,x,y,vars)
		or (id == 5 or id == 215) and side ~= 2 and side ~= 0 or (id == 6 or id == 216) and side ~= 2
		or (id == 7 or id == 217) and (side == 0 or side == 3) or (id == 8 or id == 218) and side == 0
		or id == 52 and side ~= 2 or id == 53 and (side == 0 or side == 3) or id == 54 and side == 0
		or id == 50 then 
			return 0
		end
	end
	return force+gfactor
end

function HandleGrasp(force,cell,dir,x,y,vars)
	local id = cell.id
	local rot = cell.rot
	local side = ToSide(rot,dir)
	if cell.sealed then
		vars.ended = true
		return force
	elseif type(ModStuff.custompush[cell.id]) == "function" then
		local p = ModStuff.custompush[cell.id](cell, dir, x, y, vars, side, force, "grab")
		if p == true then return force end
		if p == false then return 0 end
		if type(p) == "number" then return p end
	elseif id == 42 and side == 0 or id == 22 or id == 227 and side == 0 or id == 228 and (side == 3 or side == 0) then
		return force-1
	elseif id == 42 and side == 2 or id == 104 or id == 227 and side == 2 or id == 228 and (side == 1 or side == 2) then
		return force+1
	elseif id == 142 then
		return force == 1 and 1 or 0
	elseif id == 143 then
		return force == rot+1 and rot+1 or 0
	elseif id == 144 then
		return 1
	elseif id == 81 and vars.side == "left" or id == 82 and vars.side == "right" then
		return force == 1 and 0 or force
	elseif (id == 71 or id == 72 or id == 73 or id == 74 or id == 75 or id == 76 or id == 77 or id == 78
	or id == 272 or id == 273 or id == 274 or id == 275 or id == 280 or id == 281 or id == 282 or id == 283
	or id == 206 and cell.vars[1] == 1) and not cell.frozen then
		if side == 2 then
			vars.undocells[x+y*width] = vars.undocells[x+y*width] or table.copy(cell)	--dont update if movement fails
			cell.updated = cell.updated or not vars.noupdate
			return force+1
		elseif side == 0 then
			return force-1
		end
	elseif id == 2 or id == 14 or id == 28 or id == 58 or id == 59 or id == 60 or id == 61 or id == 114 or id == 115
	or id == 269 or id == 270 or id == 271 or id == 276 or id == 277 or id == 278 or id == 279 or id == 160 or id == 161
	or id == 175 and cell.updatekey ~= updatekey and cell.vars[1] or id == 178 or id == 179 or id == 180 or id == 181 or id == 182
	or id == 183 or id == 184 or id == 185 or id == 206 or id == 213 and (side == 0 or side == 2) or id == 303 or id == 304 or id == 305 or id == 311 then
		if side == 2 then
			vars.undocells[x+y*width] = vars.undocells[x+y*width] or table.copy(cell)
			cell.updated = cell.updated or not vars.noupdate
		end
	elseif id == 103 then
		return math.max(force-rot,0)
	elseif id == 32 or id == 33 or id == 34 or id == 35 or id == 36 or id == 37 or id == 194 or id == 195 or id == 196 or id == 197 then
		vars.ended = true
	elseif (id == 231 or id == 249) and not vars.checkonly  then
		if not vars.sticking then stickkey = stickkey + 1 end
		vars.sticking = true
		cell.stickkey = stickkey
		local func = vars.side == "left" and LGraspCell or RGraspCell
		if (dir == 1 or dir == 3) and (id == 231 or cell.rot == 0 or cell.rot == 2) then
			local c2 = GetCell(x,y-1)
			if (c2.id == 231 or c2.id == 249 and (c2.rot == 0 or c2.rot == 2)) and c2.stickkey ~= stickkey then
				local vars1 = table.copy(vars)
				vars1.force = force
				vars1.noupdate = true
				vars1.failonfirst = false
				if func(x,y-1,dir,vars1) then
					table.merge(vars.undocells,vars1.undocells)
				else
					return 0
				end
			end
			local c2 = GetCell(x,y+1)
			if (c2.id == 231 or c2.id == 249 and (c2.rot == 0 or c2.rot == 2)) and c2.stickkey ~= stickkey then
				local vars1 = table.copy(vars)
				vars1.force = force
				vars1.noupdate = true
				vars1.failonfirst = false
				if func(x,y+1,dir,vars1) then
					table.merge(vars.undocells,vars1.undocells)
				else
					return 0
				end
			end
			if GetCell(x,y) ~= cell then
				vars.ended = true
			end
		elseif (dir == 0 or dir == 2) and (id == 231 or cell.rot == 1 or cell.rot == 3) then
			local c2 = GetCell(x+1,y)
			if (c2.id == 231 or c2.id == 249 and (c2.rot == 1 or c2.rot == 3)) and c2.stickkey ~= stickkey then
				local vars1 = table.copy(vars)
				vars1.force = force
				vars1.noupdate = true
				vars1.failonfirst = false
				if func(x+1,y,dir,vars1) then
					table.merge(vars.undocells,vars1.undocells)
				else
					return 0
				end
			end
			local c2 = GetCell(x-1,y)
			if (c2.id == 231 or c2.id == 249 and (c2.rot == 1 or c2.rot == 3)) and c2.stickkey ~= stickkey then
				local vars1 = table.copy(vars)
				vars1.force = force
				vars1.noupdate = true
				vars1.failonfirst = false
				if func(x-1,y,dir,vars1) then
					table.merge(vars.undocells,vars1.undocells)
				else
					return 0
				end
			end
			if GetCell(x,y) ~= cell then
				vars.ended = true
			end
		end
	elseif IsUnbreakable(cell,(dir+(vars.side=="left" and -1 or 1))%4,x,y,vars) and not IsDestroyer(cell,(dir-2)%4,x,y,vars)
	or (id == 5 or id == 215) and side ~= 2 and side ~= 0 or (id == 6 or id == 216) and side ~= 2
	or (id == 7 or id == 217) and (side == 0 or side == 3) or (id == 8 or id == 218) and side == 0
	or (id == 52 or id == 54) and side ~= 1 and side ~= 3 then 
		vars.ended = true
		return force
	end
	return force
end

function HandlePull(force,cell,dir,x,y,vars)
	local id = cell.id
	local rot = cell.rot
	local side = ToSide(rot,dir)
	if type(ModStuff.custompush[cell.id]) == "function" then
		local p = ModStuff.custompush[cell.id](cell, dir, x, y, vars, side, force, "pull")
		if p == true then return force end
		if p == false then return 0 end
		if type(p) == "number" then return p end
	end
	if cell.sticky and not vars.checkonly then
		if not vars.sticking then stickkey = stickkey + 1 end
		vars.sticking = true
		cell.stickkey = stickkey
		if (dir == 0 or dir == 2) then
			local c2 = GetCell(x,y-1)
			if c2.sticky and c2.stickkey ~= stickkey then
				local vars1 = table.copy(vars)
				vars1.force = force
				if PullCell(x,y-1,dir,vars1) then
					table.merge(vars.undocells,vars1.undocells)
				else
					return 0
				end
			end
			local c2 = GetCell(x,y+1)
			if c2.sticky and c2.stickkey ~= stickkey then
				local vars1 = table.copy(vars)
				vars1.force = force
				if PullCell(x,y+1,dir,vars1) then
					table.merge(vars.undocells,vars1.undocells)
				else
					return 0
				end
			end
			if GetCell(x,y) ~= cell then
				vars.ended = true
			end
		elseif (dir == 1 or dir == 3) then
			local c2 = GetCell(x+1,y)
			if c2.sticky and c2.stickkey ~= stickkey then
				local vars1 = table.copy(vars)
				vars1.force = force
				if PullCell(x+1,y,dir,vars1) then
					table.merge(vars.undocells,vars1.undocells)
				else
					return 0
				end
			end
			local c2 = GetCell(x-1,y)
			if c2.sticky and c2.stickkey ~= stickkey then
				local vars1 = table.copy(vars)
				vars1.force = force
				if PullCell(x-1,y,dir,vars1) then
					table.merge(vars.undocells,vars1.undocells)
				else
					return 0
				end
			end
			if GetCell(x,y) ~= cell then
				vars.ended = true
			end
		end
	end
	if cell.latched then
		vars.ended = true
		return force
	elseif id == 42 and side == 0 or id == 22 then
		return force-1
	elseif id == 42 and side == 2 or id == 104 then
		return force+1
	elseif id == 142 then
		return force == 1 and 1 or 0
	elseif id == 143 then
		return force == rot+1 and rot+1 or 0
	elseif id == 144 then
		return 1
	elseif id == 29 then
		return force == 1 and 0 or force
	elseif (id == 14 or id == 28 or id == 73 or id == 74 or id == 61 or id == 60 or id == 77 or id == 78
	or id == 270 or id == 271 or id == 274 or id == 275 or id == 278 or id == 279 or id == 282 or id == 283
	or id == 206 and cell.vars[1] == 2) and not cell.frozen or id == 305 or id == 311 then
		if side == 2 then
			vars.undocells[x+y*width] = vars.undocells[x+y*width] or table.copy(cell)	--dont update if movement fails
			cell.updated = cell.updated or not vars.noupdate
			return force+1
		elseif side == 0 then
			return force-1
		end
	elseif id == 2 or id == 58 or id == 59 or id == 71 or id == 72 or id == 75 or id == 76 or id == 114 or id == 115
	or id == 269 or id == 272 or id == 273 or id == 276 or id == 277 or id == 280 or id == 281 or id == 160 or id == 161
	or id == 175 and cell.updatekey ~= updatekey and cell.vars[1] or id == 178 or id == 179 or id == 180 or id == 181 or id == 182
	or id == 183 or id == 184 or id == 185 or id == 206 or id == 213 and (side == 0 or side == 2) or id == 303 or id == 304 then
		if side == 2 then
			vars.undocells[x+y*width] = vars.undocells[x+y*width] or table.copy(cell)
			cell.updated = cell.updated or not vars.noupdate
		end
	elseif id == 103 then
		return math.max(force-rot,0)
	elseif id == 207 and (side == 1 or side == 3) then
		local gvars = table.copy(vars)
		gvars.force = force
		GraspEmptyCell(x,y,dir,gvars)
		table.merge(vars.undocells,gvars.undocells)
	elseif id == 32 or id == 33 or id == 34 or id == 35 or id == 36 or id == 37 or id == 194 or id == 195 or id == 196 or id == 197 then
		vars.ended = true
	elseif (id == 231 or id == 249) and not vars.checkonly then
		if not vars.sticking then stickkey = stickkey + 1 end
		vars.sticking = true
		cell.stickkey = stickkey
		if (dir == 0 or dir == 2) and (id == 231 or cell.rot == 1 or cell.rot == 3) then
			local c2 = GetCell(x,y-1)
			if (c2.id == 231 or c2.id == 249 and (c2.rot == 1 or c2.rot == 3)) and c2.stickkey ~= stickkey then
				local vars1 = table.copy(vars)
				vars1.force = force
				vars1.noupdate = true
				if PullCell(x,y-1,dir,vars1) then
					table.merge(vars.undocells,vars1.undocells)
				else
					return 0
				end
			end
			local c2 = GetCell(x,y+1)
			if (c2.id == 231 or c2.id == 249 and (c2.rot == 1 or c2.rot == 3)) and c2.stickkey ~= stickkey then
				local vars1 = table.copy(vars)
				vars1.force = force
				vars1.noupdate = true
				if PullCell(x,y+1,dir,vars1) then
					table.merge(vars.undocells,vars1.undocells)
				else
					return 0
				end
			end
			if GetCell(x,y) ~= cell then
				vars.ended = true
			end
		elseif (dir == 1 or dir == 3) and (id == 231 or cell.rot == 0 or cell.rot == 2) then
			local c2 = GetCell(x+1,y)
			if (c2.id == 231 or c2.id == 249 and (c2.rot == 0 or c2.rot == 2)) and c2.stickkey ~= stickkey then
				local vars1 = table.copy(vars)
				vars1.force = force
				vars1.noupdate = true
				if PullCell(x+1,y,dir,vars1) then
					table.merge(vars.undocells,vars1.undocells)
				else
					return 0
				end
			end
			local c2 = GetCell(x-1,y)
			if (c2.id == 231 or c2.id == 249 and (c2.rot == 0 or c2.rot == 2)) and c2.stickkey ~= stickkey then
				local vars1 = table.copy(vars)
				vars1.force = force
				vars1.noupdate = true
				if PullCell(x-1,y,dir,vars1) then
					table.merge(vars.undocells,vars1.undocells)
				else
					return 0
				end
			end
			if GetCell(x,y) ~= cell then
				vars.ended = true
			end
		end
	elseif id == 248 then
		return 0
	elseif IsUnbreakable(cell,(dir-2)%4,x,y,vars) and not IsDestroyer(cell,(dir-2)%4,x,y,vars)
	or (id == 5 or id == 215) and side ~= 2 and side ~= 0 or (id == 6 or id == 216) and side ~= 2
	or (id == 7 or id == 217) and (side == 0 or side == 3) or (id == 8 or id == 218) and side == 0
	or id == 52 and side ~= 0 or id == 53 and (side == 1 or side == 2) or id == 54 and side == 2 then 
		vars.ended = true
		return force
	end
	return force
end

function HandleSwap(cell,dir,x,y,vars)
	local id = cell.id
	local rot = cell.rot
	local side = ToSide(rot,dir)
	if type(ModStuff.custompush[cell.id]) == "function" then
		ModStuff.custompush[cell.id](cell, dir, x, y, vars, side, 1, "swap")
	end
	if (id == 12 or id == 205 or id == 225 or id == 226 or id == 300) and vars.active == "destroy" then
		Play(destroysound)
	elseif id == 244 and vars.active == "destroy" then
		if fancy then enemyparticles:setPosition(x*20-10,y*20-10) enemyparticles:emit(50) end
		Play(destroysound)
	elseif (id == 13 or id == 160 or id == 288 or id == 293 or id == 294 or id == 295 or id == 296 or id == 298) and vars.active == "destroy"  then
		cell.id = 0
		if fancy then enemyparticles:setPosition(x*20-10,y*20-10) enemyparticles:emit(50) end
		Play(destroysound)
	elseif id == 24 and vars.active == "destroy" then
		cell.id = 13
		if fancy then enemyparticles:setPosition(x*20-10,y*20-10) enemyparticles:emit(50) end
		Play(destroysound)
	elseif id == 164 and vars.active == "destroy" then
		cell.rot = cell.rot - 1
		if cell.rot == -1 then
			cell.id = 0
		end
		if fancy then swivelparticles:setPosition(x*20-10,y*20-10) swivelparticles:emit(50) end
		Play(destroysound)
	elseif id == 299 and vars.active == "destroy" then
		DoQuantumEnemy(cell,vars)
		Play(destroysound)
	elseif id == 154 and vars.lastcell.id == 153 then
		SetCell(x,y,getempty())
		if fancy then sparkleparticles:setPosition(x*20-10,y*20-10) sparkleparticles:emit(50) end
		Play(unlocksound)
	elseif id == 165 or id == 175 and (cell.updatekey == updatekey or not cell.vars[1]) then
		cell.updatekey = updatekey
		if cell.vars[1] then
			local cx,cy = x,y
			if dir == 0 then cx = x+1 elseif dir == 2 then cx = x-1 end
			if dir == 1 then cy = y+1 elseif dir == 3 then cy = y-1 end
			PushCell(cx,cy,dir,{force=1,replacecell={
			id=cell.vars[1],rot=cell.vars[2],lastvars={x,y,cell.vars[2]},updated=true,vars = DefaultVars(cell.vars[1])}})
			cell.vars = {}
		end
		if not IsNonexistant(vars.lastcell,dir,x,y) then
			cell.vars[1] = vars.lastcell.id
			cell.vars[2] = vars.lastcell.rot
		end
	elseif id == 198 and side == 2 then
		if cell.vars[1] then
			local cx,cy = x,y
			if dir == 0 then cx = x+1 elseif dir == 2 then cx = x-1 end
			if dir == 1 then cy = y+1 elseif dir == 3 then cy = y-1 end
			local rc = table.copy(vars.lastcell)
			rc.id = cell.vars[1]
			rc.rot = cell.vars[2]
			PushCell(cx,cy,dir,{force=1,replacecell=rc})
		elseif not IsNonexistant(vars.lastcell,dir,x,y) then
			cell.vars[1] = vars.lastcell.id
			cell.vars[2] = vars.lastcell.rot
		end
	elseif id == 51 then
		local neighbors = GetNeighbors(x,y)
		for k,v in pairs(neighbors) do
			local c = GetCell(v[1],v[2])
			if not IsUnbreakable(c,k,v[1],v[2],{forcetype="destroy",lastcell=cell}) then
				SetCell(v[1],v[2],getempty())
				GetCell(v[1],v[2]).eatencells = {c}
			end
		end
		Play(destroysound)
	elseif id == 141 then
		local neighbors = GetSurrounding(x,y)
		for k,v in pairs(neighbors) do
			local c = GetCell(v[1],v[2])
			if not IsUnbreakable(c,k,v[1],v[2],{forcetype="destroy",lastcell=cell}) then
				SetCell(v[1],v[2],getempty())
				GetCell(v[1],v[2]).eatencells = {c}
			end
		end
		Play(destroysound)
	elseif id == 176 then
		SetCell(vars.lastx,vars.lasty,table.copy(cell))
		Play(destroysound)
		Play(infectsound)
	end
end

function CanMove(cell,dir,x,y,ftype,force)
	local vars = {noupdate=true,checkonly=true,lastcell=getempty(),undocells={}}
	if ftype == "pull" then
		return HandlePull(force or 1,cell,dir,x,y,vars) > 0 and not IsDestroyer(cell,dir,x,y,{forcetype="pull"}) and not vars.ended
	elseif ftype == "grasp" then
		return HandleGrasp(force or 1,cell,dir,x,y,vars) > 0 and not IsDestroyer(cell,dir,x,y,{forcetype="grasp"}) and not vars.ended
	else
		return HandlePush(force or 1,cell,dir,x,y,vars) > 0 and not IsDestroyer(cell,dir,x,y,{forcetype="push"}) and not vars.ended
	end
end

function NudgeCell(x,y,dir,vars)
	vars = vars or {}
	local cell = GetCell(x,y)
	if IsNonexistant(cell,dir,x,y) then return true end
	local cx,cy,cdir,newcell = NextCell(x,y,dir,table.copy(cell))
	if cx then
		local checkedcell = GetCell(cx,cy)
		vars.forcetype = "nudge"
		vars.lastcell = cell
		vars.lastx,vars.lasty,vars.lastdir = x,y,dir
		if IsDestroyer(checkedcell,cdir,cx,cy,vars) and (x ~= cx or y ~= cy) then
			SetCell(x,y,getempty())
			vars.active = "destroy"
			if fancy then checkedcell.eatencells = checkedcell.eatencells or {}; table.insert(checkedcell.eatencells,vars.lastcell) end
			HandleNudge(checkedcell,cdir,cx,cy,vars)
			return true,cx,cy,cdir
		elseif IsNonexistant(checkedcell,cdir,cx,cy,vars) or x == cx and y == cy then
			if vars.undocells then vars.undocells[cx+cy*width] = vars.undocells[cx+cy*width] or checkedcell end
			SetCell(x,y,getempty())
			SetCell(cx,cy,newcell)
			vars.active = "replace"
			vars.lastcell = newcell
			HandleNudge(checkedcell,cdir,cx,cy,vars)
			return true,cx,cy,cdir
		end
		HandleNudge(checkedcell,cdir,cx,cy,vars)
	end
	return false,cx,cy,cdir
end

function NudgeCellTo(lastcell,x,y,dir,vars)
	local checkedcell = GetCell(x,y)
	vars.lastcell = lastcell
	if IsDestroyer(checkedcell,dir,x,y,vars) then
		vars.active = "destroy"
		if fancy then checkedcell.eatencells = checkedcell.eatencells or {}; table.insert(checkedcell.eatencells,vars.lastcell) end
		HandleNudge(checkedcell,dir,x,y,vars)
		return true,x,y,dir
	elseif IsTransparent(checkedcell,dir,x,y,vars) then
		if vars.undocells then vars.undocells[x+y*width] = vars.undocells[x+y*width] or checkedcell end
		SetCell(x,y,lastcell)
		vars.active = "replace"
		HandleNudge(checkedcell,dir,x,y,vars)
		return true,x,y,dir
	end
	return false,x,y,dir
end

function PushCell(x,y,dir,vars)
	vars = vars or {}
	local startcell = GetCell(x,y)
	if startcell.id == 231 or startcell.id == 249 and startcell.rot%2 == dir%2 or startcell.sticky then
		local cx,cy = x,y
		if dir == 0 then cx = x-1 elseif dir == 2 then cx = x+1
		elseif dir == 1 then cy = y-1 elseif dir == 3 then cy = y+1 end
		if (GetCell(cx,cy).id == 231 or GetCell(cx,cy).id == 249 and GetCell(cx,cy).rot%2 == dir%2 or GetCell(cx,cy).sticky) and GetCell(cx,cy).stickkey ~= stickkey then
			return PushCell(cx,cy,dir,vars)
		end
	end
	if dir == 0 then x = x-1 elseif dir == 2 then x = x+1
	elseif dir == 1 then y = y-1 elseif dir == 3 then y = y+1 end
	local cx,cy,cdir = x,y,dir
	local force = vars.force or 0
	if startcell.vars.gravdir == dir then	--mover shenanigans
		force = force - 1
	end
	vars.lastcell = vars.replacecell or getempty()
	vars.forcetype = "push"
	vars.undocells = vars.undocells or {}
	vars.optimizegen = true
	updatekey = updatekey + 1
	repeat
		vars.lastx,vars.lasty,vars.lastdir = cx,cy,cdir
		cx,cy,cdir = NextCell(cx,cy,cdir,vars.lastcell)
		if not cx then force = 0 break end
		local oldcell = GetCell(cx,cy)
		vars.destroying = IsDestroyer(oldcell,cdir,cx,cy,vars)
		force = HandlePush(force,oldcell,cdir,cx,cy,vars)
		oldcell.testvar = force
		if vars.ended then break end	--silicon
		if IsDestroyer(oldcell,cdir,cx,cy,vars) then
			if fancy then oldcell.eatencells = oldcell.eatencells or {}; table.insert(oldcell.eatencells,vars.lastcell) end
		else vars.undocells[cx+cy*width] = vars.undocells[cx+cy*width] or oldcell SetCell(cx,cy,vars.lastcell) end
		vars.ended = IsTransparent(oldcell,cdir,cx,cy,vars)
		vars.lastcell = table.copy(oldcell)
		local data = GetData(cx,cy)
		if data.updatekey == updatekey and data.crosses >= 5 then
			force = 0
			break
		else
			data.crosses = data.updatekey == updatekey and data.crosses + 1 or 1
		end
		data.updatekey = updatekey
	until force <= 0 or vars.ended
	if force <= 0 then
		for k,v in pairs(vars.undocells) do
			SetCell(k%width,math.floor(k/width),v)
		end
		return false,vars.optimizegen
	end
	Play(movesound)
	return true,false
end

function LGraspCell(x,y,dir,vars)
	local startcell = GetCell(x,y)
	if startcell.id == 231 or startcell.id == 249 and startcell.rot%2 ~= dir%2 or startcell.sticky then
		local cx,cy = x,y
		if dir == 1 then cx = x-1 elseif dir == 3 then cx = x+1
		elseif dir == 2 then cy = y-1 elseif dir == 0 then cy = y+1 end
		if (GetCell(cx,cy).id == 231 or GetCell(cx,cy).id == 249 and GetCell(cx,cy).rot%2 ~= dir%2 or GetCell(cx,cy).sticky) and GetCell(cx,cy).stickkey ~= stickkey then
			return LGraspCell(cx,cy,dir,vars)
		end
	end
	if dir == 3 then x = x+1 elseif dir == 1 then x = x-1
	elseif dir == 0 then y = y+1 elseif dir == 2 then y = y-1 end
	local cx,cy,cdir = x,y,dir
	vars = vars or {}
	vars.lastcell = getempty()
	vars.undocells = {}
	vars.undocells[cx+cy*width] = vars.undocells[cx+cy*width] or GetCell(cx,cy)
	vars.side = "left"
	local force = vars.force or 0
	updatekey = updatekey + 1
	local firstloop = true
	repeat
		vars.forcetype = "grasp"
		vars.lastx,vars.lasty,vars.lastdir = cx,cy,cdir
		cx,cy,cdir = NextCell(cx,cy,(cdir-1)%4,vars.lastcell)
		if not cx then force = 0 break end
		cdir = (cdir+1)%4
		local oldcell = GetCell(cx,cy)
		force = HandleGrasp(force,oldcell,cdir,cx,cy,vars)
		oldcell.testvar = force
		if oldcell.pulledside == ToSide(oldcell.rot,cdir) and oldcell.updatekey == updatekey then vars.ended = true end
		oldcell.pulledside = ToSide(oldcell.rot,cdir)
		oldcell.updatekey = updatekey
		vars.undocells[cx+cy*width] = vars.undocells[cx+cy*width] or oldcell
		local transparent = IsTransparent(oldcell,(cdir-1)%4,cx,cy,vars)
		vars.ended = vars.ended or transparent or not NudgeCell(cx,cy,cdir,vars)
		if vars.ended then firstloop = (not transparent) and firstloop SetCell(cx,cy,vars.undocells[cx+cy*width]) break end
		vars.lastcell = getempty()
		firstloop = false
		local data = GetData(cx,cy)
		if data.updatekey == updatekey and data.crosses >= 5 then
			force = 0
			break
		else
			data.crosses = data.updatekey == updatekey and data.crosses + 1 or 1
		end
		data.updatekey = updatekey
	until force <= 0 or vars.ended or cx == x and cy == y and cdir == dir
	if force <= 0 then
		for k,v in pairs(vars.undocells) do
			SetCell(k%width,math.floor(k/width),v)
		end
		return false
	end
	return not vars.failonfirst or not firstloop,force
end

function RGraspCell(x,y,dir,vars)
	local startcell = GetCell(x,y)
	if startcell.id == 231 or startcell.id == 249 and startcell.rot%2 ~= dir%2 or startcell.sticky then
		local cx,cy = x,y
		if dir == 3 then cx = x-1 elseif dir == 1 then cx = x+1
		elseif dir == 0 then cy = y-1 elseif dir == 2 then cy = y+1 end
		if (GetCell(cx,cy).id == 231 or GetCell(cx,cy).id == 249 and GetCell(cx,cy).rot%2 ~= dir%2 or GetCell(cx,cy).sticky) and GetCell(cx,cy).stickkey ~= stickkey then
			return RGraspCell(cx,cy,dir,vars)
		end
	end
	if dir == 1 then x = x+1 elseif dir == 3 then x = x-1
	elseif dir == 2 then y = y+1 elseif dir == 0 then y = y-1 end
	local cx,cy,cdir = x,y,dir
	vars = vars or {}
	vars.lastcell = getempty()
	vars.undocells = {}
	vars.undocells[cx+cy*width] = vars.undocells[cx+cy*width] or GetCell(cx,cy)
	vars.side = "right"
	local force = vars.force or 0
	updatekey = updatekey + 1
	local firstloop = true
	repeat
		vars.forcetype = "grasp"
		vars.lastx,vars.lasty,vars.lastdir = cx,cy,cdir
		cx,cy,cdir = NextCell(cx,cy,(cdir+1)%4,vars.lastcell)
		if not cx then force = 0 break end
		cdir = (cdir-1)%4
		local oldcell = GetCell(cx,cy)
		force = HandleGrasp(force,oldcell,cdir,cx,cy,vars)
		oldcell.testvar = force
		if oldcell.pulledside == ToSide(oldcell.rot,cdir) and oldcell.updatekey == updatekey then vars.ended = true end
		oldcell.pulledside = ToSide(oldcell.rot,cdir)
		oldcell.updatekey = updatekey
		vars.undocells[cx+cy*width] = vars.undocells[cx+cy*width] or oldcell
		local transparent = IsTransparent(oldcell,(cdir+1)%4,cx,cy,vars)
		vars.ended = vars.ended or transparent or not NudgeCell(cx,cy,cdir,vars)
		if vars.ended then firstloop = (not transparent) and firstloop SetCell(cx,cy,vars.undocells[cx+cy*width]) break end
		vars.lastcell = getempty()
		firstloop = false
		local data = GetData(cx,cy)
		if data.updatekey == updatekey and data.crosses >= 5 then
			force = 0
			break
		else
			data.crosses = data.updatekey == updatekey and data.crosses + 1 or 1
		end
		data.updatekey = updatekey
	until force <= 0 or vars.ended or cx == x and cy == y and cdir == dir
	if force <= 0 then
		for k,v in pairs(vars.undocells) do
			SetCell(k%width,math.floor(k/width),v)
		end
		return false
	end
	return not vars.failonfirst or not firstloop,force
end

function GraspCell(x,y,dir,vars)
	vars = vars or {}
	local vars1 = table.copy(vars)
	vars1.failonfirst = true
	local oldcell = GetCell(x,y)
	local success,force = LGraspCell(x,y,dir,vars1)
	if success and GetCell(x,y) ~= oldcell then
		vars.force = force
		if dir == 3 then x = x+1 elseif dir == 1 then x = x-1
		elseif dir == 0 then y = y+1 elseif dir == 2 then y = y-1 end
		local success2,undocells2 = RGraspCell(x,y,dir,vars)
		if not success2 then
			for k,v in pairs(vars1.undocells) do
				SetCell(k%width,math.floor(k/width),v)
			end
			return false
		end
		if dir == 3 then x = x-1 elseif dir == 1 then x = x+1
		elseif dir == 0 then y = y-1 elseif dir == 2 then y = y+1 end
	else return false end
	table.merge(vars.undocells,vars1.undocells)
	Play(movesound)
	return true
end

function GraspEmptyCell(x,y,dir,vars)	--convenience
	vars = vars or {}
	local vars1 = table.copy(vars)
	if dir == 3 then x = x-1 elseif dir == 1 then x = x+1
	elseif dir == 0 then y = y-1 elseif dir == 2 then y = y+1 end
	local success,force = LGraspCell(x,y,dir,vars1)
	if success then
		vars.force = force
		if dir == 3 then x = x+2 elseif dir == 1 then x = x-2
		elseif dir == 0 then y = y+2 elseif dir == 2 then y = y-2 end
		local success2 = RGraspCell(x,y,dir,vars)
		if not success2 then
			for k,v in pairs(vars1.undocells) do
				SetCell(k%width,math.floor(k/width),v)
			end
			return false
		end
		if dir == 3 then x = x-1 elseif dir == 1 then x = x+1
		elseif dir == 0 then y = y-1 elseif dir == 2 then y = y+1 end
	else return false end
	table.merge(vars.undocells,vars1.undocells)
	Play(movesound)
	return true
end

function PullCell(x,y,dir,vars)
	local startcell = GetCell(x,y)
	if startcell.id == 231 or startcell.id == 249 and startcell.rot%2 == dir%2 or startcell.sticky then
		local cx,cy = x,y
		if dir == 2 then cx = x-1 elseif dir == 0 then cx = x+1
		elseif dir == 3 then cy = y-1 elseif dir == 1 then cy = y+1 end
		if (GetCell(cx,cy).id == 231 or GetCell(cx,cy).id == 249 and GetCell(cx,cy).rot%2 == dir%2 or GetCell(cx,cy).sticky) and GetCell(cx,cy).stickkey ~= stickkey then
			return PullCell(cx,cy,dir,vars)
		end
	end
	local oldcell = GetCell(x,y)
	if dir == 0 then x = x+1 elseif dir == 2 then x = x-1
	elseif dir == 1 then y = y+1 elseif dir == 3 then y = y-1 end
	local cx,cy,cdir = x,y,dir
	vars = vars or {}
	vars.lastcell = getempty()
	vars.undocells = vars.undocells or {}
	vars.undocells[cx+cy*width] = vars.undocells[cx+cy*width] or GetCell(cx,cy)
	local force = vars.force or 0
	updatekey = updatekey + 1
	repeat
		vars.forcetype = "pull"
		vars.lastx,vars.lasty,vars.lastdir = cx,cy,cdir
		cx,cy,cdir = NextCell(cx,cy,(cdir+2)%4,vars.lastcell,true)
		if not cx then force = 0 break end
		cdir = (cdir+2)%4
		local oldcell = GetCell(cx,cy)
		force = HandlePull(force,oldcell,cdir,cx,cy,vars)
		oldcell.testvar = force
		if oldcell.pulledside == ToSide(oldcell.rot,cdir) and oldcell.updatekey == updatekey then vars.ended = true end
		oldcell.pulledside = ToSide(oldcell.rot,cdir)
		oldcell.updatekey = updatekey
		vars.undocells[cx+cy*width] = vars.undocells[cx+cy*width] or oldcell
		vars.ended = vars.ended or IsTransparent(oldcell,(cdir+2)%4,cx,cy,vars) or not NudgeCell(cx,cy,cdir,vars)
		vars.lastcell = getempty()
		local data = GetData(cx,cy)
		if data.updatekey == updatekey and data.crosses >= 5 then
			force = 0
			break
		else
			data.crosses = data.updatekey == updatekey and data.crosses + 1 or 1
		end
		data.updatekey = updatekey
	until force <= 0 or vars.ended or cx == x and cy == y and cdir == dir
	if force <= 0 then
		for k,v in pairs(vars.undocells) do
			SetCell(k%width,math.floor(k/width),v)
		end
		return false
	end
	if dir == 0 then x = x-1 elseif dir == 2 then x = x+1
	elseif dir == 1 then y = y-1 elseif dir == 3 then y = y+1 end
	if GetCell(x,y) ~= oldcell or vars.dontfailonfirst or IsNonexistant(oldcell,dir,x,y,vars) then Play(movesound) return true end
	return false
end

function SwapCells(x1,y1,dir1,x2,y2,dir2)
	local cell1 = GetCell(x1,y1)
	local cell2 = CopyCell(x2,y2)
	local dest1,dest2 = IsDestroyer(cell1,dir1,x1,y1,{lastcell=cell2,forcetype="swap",lastx=x2,lasty=y2}),IsDestroyer(cell2,dir2,x2,y2,{lastcell=cell1,lastx=x1,lasty=y1,forcetype="swap"})
	local unb1,unb2 = IsUnbreakable(cell1,dir1,x1,y1,{lastcell=cell2,forcetype="swap",lastx=x2,lasty=y2}),IsUnbreakable(cell2,dir2,x2,y2,{lastcell=cell1,lastx=x1,lasty=y1,forcetype="swap"})
	GetCell(x1,y1).testvar = "A"
	GetCell(x2,y2).testvar = "A"
	if (not unb1 or dest1) or (not unb2 or dest2) then
		if dest1 and not dest2 and not unb2 and not IsNonexistant(cell2,dir2,x2,y2) then
			SetCell(x2,y2,getempty())
			if fancy then GetCell(x1,y1).eatencells = GetCell(x1,y1).eatencells or {}; table.insert(GetCell(x1,y1).eatencells,cell2) end
			HandleSwap(GetCell(x1,y1),dir1,x1,y1,{lastcell=cell2,lastx=x2,lasty=y2,active="destroy"})
			Play(movesound)
			return true
		elseif not dest1 and not unb1 and dest2 and not IsNonexistant(cell1,dir1,x1,y1) then
			SetCell(x1,y1,getempty())
			if fancy then GetCell(x2,y2).eatencells = GetCell(x2,y2).eatencells or {}; table.insert(GetCell(x2,y2).eatencells,cell1) end
			HandleSwap(GetCell(x2,y2),dir2,x2,y2,{lastcell=cell1,lastx=x1,lasty=y1,active="destroy"})
			Play(movesound)
			return true
		elseif unb1 and not unb2 and not IsNonexistant(cell2,dir2,x2,y2) then
			HandleSwap(GetCell(x1,y1),dir1,x1,y1,{lastcell=GetCell(x2,y2),lastx=x2,lasty=y2})
			return false
		elseif not unb1 and unb2 and not IsNonexistant(cell1,dir1,x1,y1) then
			HandleSwap(GetCell(x2,y2),dir2,x2,y2,{lastcell=cell1,lastx=x1,lasty=y1})
			return false
		elseif not dest1 and not dest2 and not unb1 and not unb2 then
			SetCell(x2,y2,cell1)
			SetCell(x1,y1,cell2)
			HandleSwap(GetCell(x1,y1),dir1,x1,y1,{lastcell=GetCell(x2,y2),lastx=x2,lasty=y2,active="swap"})
			HandleSwap(GetCell(x2,y2),dir2,x2,y2,{lastcell=cell1,lastx=x1,lasty=y1,active="swap"})
			Play(movesound)
			return true
		end
	end
	return false
end

function RunOn(runwhen,torun,direction,chunktype)
	if not chunks.all[chunktype] then return false end
	local right,down,xfirst
	right = direction == "rightdown" or direction == "downright" or direction == "rightup" or direction == "upright"
	down = direction == "rightdown" or direction == "downright" or direction == "leftdown" or direction == "downleft"
	xfirst = direction == "rightdown" or direction == "leftdown" or direction == "rightup" or direction == "leftup"
	local didsomething = false
	if xfirst then
		local cx = right and 0 or width-1
		local cy = down and 0 or height-1
		while down and cy < height or not down and cy >= 0 do
			cx = right and 0 or width-1
			local hasrow = false
			while right and cx < width or not right and cx >= 0 do
				if GetChunk(cx,cy,chunktype) then
					local cell = cells[cy][cx]
					if runwhen(cell) then
						torun(cx,cy,cell)
						updatekey = updatekey + 1
						didsomething = true
					end
					hasrow = true
					cx = cx + (right and 1 or -1)
				else
					cx = cx + (right and 25 or -((cx)%25+1))
				end
			end
			if hasrow then
				cy = cy + (down and 1 or -1)
			else
				cy = cy + (down and 25 or -((cy)%25+1))
			end
		end
	else
		local cx = right and 0 or width-1
		local cy = down and 0 or height-1
		while right and cx < width or not right and cx >= 0 do
			cy = down and 0 or height-1
			local hasrow = false
			while down and cy < height or not down and cy >= 0 do
				if GetChunk(cx,cy,chunktype) then
					local cell = cells[cy][cx]
					if runwhen(cell) then
						torun(cx,cy,cell)
						updatekey = updatekey + 1
						didsomething = true
					end
					hasrow = true
					cy = cy + (down and 1 or -1)
				else
					cy = cy + (down and 25 or -((cy)%25+1))
				end
			end
			if hasrow then
				cx = cx + (right and 1 or -1)
			else
				cx = cx + (right and 25 or -((cx)%25+1))
			end
		end
	end
	return didsomething
end

function CheckEnemies()
	if puzzle then
		clear = true
		RunOn(function(c) return IsEnemy(c.id) end,
		function() clear = false end,
		"rightup",
		"enemy") 
		if clear then
			TogglePause(true)
			inmenu = false
			winscreen = true
		end
	end
end

function DoCheater(x,y,cell)
	cell.updated = true
	if cell.id == 199 then
		local dir = cell.rot
		if dir == 0 then x = x-1 elseif dir == 2 then x = x+1
		elseif dir == 1 then y = y-1 elseif dir == 3 then y = y+1 end
		vars = vars or {}
		local cx,cy = x,y
		vars.lastcell = getempty()
		repeat
			local origrot = vars.lastcell.rot
			if dir == 0 then cx = cx+1 elseif dir == 2 then cx = cx-1
			elseif dir == 1 then cy = cy+1 elseif dir == 3 then cy = cy-1 end
			local oldcell = GetCell(cx,cy)
			SetCell(cx,cy,vars.lastcell)
			vars.ended = IsNonexistant(oldcell,cdir,cx,cy,vars)
			vars.lastcell = table.copy(oldcell)
		until vars.ended
		Play(movesound)
	elseif cell.id == 200 then
		local dir = cell.rot
		local cx,cy = x,y
		while not IsNonexistant(GetCell(cx,cy),dir,cx,cy) do
			if dir == 0 then cx = cx-1 elseif dir == 2 then cx = cx+1
			elseif dir == 1 then cy = cy-1 elseif dir == 3 then cy = cy+1 end
		end
		vars = vars or {}
		vars.lastcell = getempty()
		repeat
			local origrot = vars.lastcell.rot
			if dir == 0 then cx = cx+1 elseif dir == 2 then cx = cx-1
			elseif dir == 1 then cy = cy+1 elseif dir == 3 then cy = cy-1 end
			local oldcell = GetCell(cx,cy)
			if oldcell.id == 200 and oldcell.rot == dir then oldcell.updated = true end
			SetCell(cx,cy,vars.lastcell)
			vars.ended = IsNonexistant(oldcell,cdir,cx,cy,vars)
			vars.lastcell = table.copy(oldcell)
		until vars.ended
		Play(movesound)
	elseif cell.id == 201 then
		local cx,cy = x,y
		if cell.rot == 0 then cx = x+1 elseif cell.rot == 2 then cx = x-1
		elseif cell.rot == 1 then cy = y+1 elseif cell.rot == 3 then cy = y-1 end
		local cell2 = GetCell(cx,cy)
		SetCell(cx,cy,cell)
		SetCell(x,y,cell2)
		Play(movesound)
	elseif cell.id == 202 then
		local cx,cy,cx2,cy2 = x,y,x,y
		if cell.rot == 0 then cx = x+1 elseif cell.rot == 2 then cx = x-1
		elseif cell.rot == 1 then cy = y+1 elseif cell.rot == 3 then cy = y-1 end
		if cell.rot == 0 then cx2 = x-1 elseif cell.rot == 2 then cx2 = x+1
		elseif cell.rot == 1 then cy2 = y-1 elseif cell.rot == 3 then cy2 = y+1 end
		local cell = GetCell(cx,cy)
		local cell2 = GetCell(cx2,cy2)
		SetCell(cx2,cy2,cell)
		SetCell(cx,cy,cell2)
		Play(movesound)
	elseif cell.id == 203 then
		local neighbors = GetSurrounding(x,y)
		GetCell(neighbors[0.5][1],neighbors[0.5][2]).rot = (GetCell(neighbors[0.5][1],neighbors[0.5][2]).rot + 1)%4
		GetCell(neighbors[1.5][1],neighbors[1.5][2]).rot = (GetCell(neighbors[1.5][1],neighbors[1.5][2]).rot + 1)%4
		GetCell(neighbors[2.5][1],neighbors[2.5][2]).rot = (GetCell(neighbors[2.5][1],neighbors[2.5][2]).rot + 1)%4
		GetCell(neighbors[3.5][1],neighbors[3.5][2]).rot = (GetCell(neighbors[3.5][1],neighbors[3.5][2]).rot + 1)%4
		local lastcell = getempty()
		for i=0,3.5,.5 do
			local v = neighbors[i]
			local cell = CopyCell(v[1],v[2])
			SetCell(v[1],v[2],lastcell)
			lastcell = cell
		end
		local v = neighbors[0]
		local cell = CopyCell(v[1],v[2])
		SetCell(v[1],v[2],lastcell)
		Play(movesound)
	elseif cell.id == 204 then
		local neighbors = GetSurrounding(x,y)
		GetCell(neighbors[0.5][1],neighbors[0.5][2]).rot = (GetCell(neighbors[0.5][1],neighbors[0.5][2]).rot - 1)%4
		GetCell(neighbors[1.5][1],neighbors[1.5][2]).rot = (GetCell(neighbors[1.5][1],neighbors[1.5][2]).rot - 1)%4
		GetCell(neighbors[2.5][1],neighbors[2.5][2]).rot = (GetCell(neighbors[2.5][1],neighbors[2.5][2]).rot - 1)%4
		GetCell(neighbors[3.5][1],neighbors[3.5][2]).rot = (GetCell(neighbors[3.5][1],neighbors[3.5][2]).rot - 1)%4
		local lastcell = getempty()
		for i=3.5,0,-.5 do
			local v = neighbors[i]
			local cell = CopyCell(v[1],v[2])
			SetCell(v[1],v[2],lastcell)
			lastcell = cell
		end
		local v = neighbors[3.5]
		local cell = CopyCell(v[1],v[2])
		SetCell(v[1],v[2],lastcell)
		Play(movesound)
	end
end

function DoThawer(x,y,cell)
	local neighbors = GetNeighbors(x,y)
	for k,v in pairs(neighbors) do
		ThawCell(v[1],v[2],k)
	end
	cell.thawed = true
end

function DoFreezer(x,y,cell)
	if cell.id == 286 then
		local neighbors = GetSurrounding(x,y)
		for k,v in pairs(neighbors) do
			FreezeCell(v[1],v[2],k,true)
		end
	elseif cell.id == 287 then
		local neighbors = GetNeighbors(x,y)
		if cell.rot == 0 or cell.rot == 2 then
			FreezeCell(neighbors[2][1],neighbors[2][2],2)
			FreezeCell(neighbors[0][1],neighbors[0][2],0)
		else
			FreezeCell(neighbors[1][1],neighbors[1][2],1)
			FreezeCell(neighbors[3][1],neighbors[3][2],3)
		end
	else
		local neighbors = GetNeighbors(x,y)
		for k,v in pairs(neighbors) do
			FreezeCell(v[1],v[2],k)
		end
	end
	cell.frozen = true
end

function DoEffectGiver(x,y,cell)
	if cell.id == 43 then
		local neighbors = GetSurrounding(x,y)
		for k,v in pairs(neighbors) do
			ProtectCell(v[1],v[2],k)
		end
		cell.protected = true
	elseif cell.id == 112 then
		local neighbors = GetNeighbors(x,y)
		for k,v in pairs(neighbors) do
			LockCell(v[1],v[2],k)
		end
		cell.locked = true
	elseif cell.id == 145 then
		for cx=x-2,x+2 do
			for cy=y-2,y+2 do
				ProtectCell(cx,cy,0,1)
			end
		end
	elseif cell.id == 136 then
		local neighbors = GetNeighbors(x,y)
		for k,v in pairs(neighbors) do
			ClampCell(v[1],v[2],k)
		end
		cell.clamped = true
	elseif cell.id == 137 then
		local neighbors = GetNeighbors(x,y)
		for k,v in pairs(neighbors) do
			LatchCell(v[1],v[2],k)
		end
		cell.latched = true
	elseif cell.id == 138 then
		local neighbors = GetNeighbors(x,y)
		for k,v in pairs(neighbors) do
			SealCell(v[1],v[2],k)
		end
		cell.sealed = true
	elseif cell.id == 139 then
		local neighbors = GetNeighbors(x,y)
		for k,v in pairs(neighbors) do
			BoltCell(v[1],v[2],k)
		end
		cell.bolted = true
	elseif cell.id == 253 then
		local neighbors = GetNeighbors(x,y)
		for k,v in pairs(neighbors) do
			ReinforceCell(v[1],v[2],k)
		end
		cell.reinforced = true
	elseif cell.id == 232 then
		local neighbors = GetNeighbors(x,y)
		for k,v in pairs(neighbors) do
			GravitizeCell(v[1],v[2],k,cell.rot)
		end
	elseif cell.id == 252 then
		local neighbors = GetNeighbors(x,y)
		for k,v in pairs(neighbors) do
			StickCell(v[1],v[2],k)
		end
		cell.sticky = true
	elseif cell.id == 308 then
		local neighbors = GetNeighbors(x,y)
		for k,v in pairs(neighbors) do
			ProtectCell(v[1],v[2],k,-1)
		end
		cell.protected = true
	elseif cell.id == 309 then
		cell.protected = true
	elseif cell.id == 310 then
		local neighbors = GetNeighbors(x,y)
		table.insert(neighbors,{x,y})
		for k,v in pairs(neighbors) do
			ClampCell(v[1],v[2],k)
			LatchCell(v[1],v[2],k)
			SealCell(v[1],v[2],k)
			BoltCell(v[1],v[2],k)
			ReinforceCell(v[1],v[2],k)
		end
	end
end

function DoDegravitizer(x,y,cell)
	local neighbors = GetNeighbors(x,y)
	for k,v in pairs(neighbors) do
		GravitizeCell(v[1],v[2],k,nil)
	end
	cell.vars.gravdir = nil
end

function DoTimewarper(x,y,cell,dir)
	if cell.id == 146 or cell.id == 148 then
		if cell.id == 146 or dir == 1 or dir == 3 then cell.updated = true
		else cell.hupdated = true end
		cell.updated = true
		local cx,cy,cdir = NextCell(x,y,dir)
		if cx then
			local cell2 = GetCell(cx,cy)
			if not IsUnbreakable(cell2,cdir,cx,cy,{forcetype="transform",lastcell=cell}) then
				local c = table.copy(initial[cy][cx])
				c.lastvars = table.copy(cell2.lastvars)
				c.lastvars[3] = c.rot
				c.eatencells = {cell2}
				SetCell(cx,cy,c)
			end
		end
	elseif cell.id == 147 then
		cell.updated = true
		local cx,cy,cdir = NextCell(x,y,(dir+2)%4,nil,true)
		if cx then
			local gencell = table.copy(initial[cy][cx])
			gencell.rot = (gencell.rot-c.rot)%4
			gencell = ToGenerate(gencell,cdir,cx,cy)
			if gencell then
				gencell.lastvars = table.copy(cell.lastvars)
				gencell.lastvars[3] = gencell.rot
				if dir == 0 then x = x + 1 elseif dir == 2 then x = x - 1
				elseif dir == 1 then y = y + 1 elseif dir == 3 then y = y - 1 end
				PushCell(x,y,dir,{replacecell=gencell,noupdate=true,force=1})
			end
		end
	end
end

function DoTransformer(x,y,cell,dir)
	if cell.id == 237 or cell.id == 267 or dir == 1 or dir == 3 then cell.updated = true
	else cell.hupdated = true end
	local cx,cy,cdir = NextCell(x,y,(dir+2)%4,nil,true)
	local ccx,ccy,ccdir = NextCell(x,y,dir)
	if cx and ccx then
		local cell2 = GetCell(ccx,ccy)
		local cell1 = GetCell(cx,cy)
		local copycell = CopyCell(cx,cy)
		NextCell(cx,cy,(cdir+2)%4,copycell)
		if not IsNonexistant(cell2,cdir,cx,cy) and not IsNonexistant(copycell,ccdir,ccx,ccy) and not IsUnbreakable(cell2,ccdir,ccx,ccy,{forcetype="transform",lastcell=cell}) and
		((cell.id == 237 or cell.id == 238) or not IsUnbreakable(copycell,cdir,cx,cy,{forcetype="pull",lastcell=cell})) then
			NextCell(x,y,dir,copycell)
			copycell.lastvars = table.copy(cell2.lastvars)
			copycell.lastvars[3] = copycell.rot
			copycell.eatencells = {cell2}
			if cell.id == 267 or cell.id == 268 then
				SetCell(cx,cy,getempty())
				SetCell(ccx,ccy,copycell)
				local px,py = cx,cy
				if cdir == 0 then px = cx + 1 elseif cdir == 2 then px = cx - 1
				elseif cdir == 1 then py = cy + 1 elseif cdir == 3 then py = cy - 1 end
				if not CanMove(copycell,cx,cy,cdir,"pull") or not PullCell(px,py,(cdir+2)%4,{force=1,noupdate=true}) then
					SetCell(cx,cy,cell1)
					SetCell(ccx,ccy,cell2)
				else
					cell.eatencells = cell.eatencells or {}
					table.insert(cell.eatencells,cell1)
				end
			else
				SetCell(ccx,ccy,copycell)
			end
		end
	end
end

function DoHMirror(x,y,cell)
	local cell1 = GetCell(x+1,y)
	local cell2 = GetCell(x-1,y)
	if not ((cell1.id == 15 and (cell1.rot == 0 or cell1.rot == 2) or cell1.id == 56 or cell1.id == 80)
	or (cell2.id == 15 and (cell2.rot == 0 or cell2.rot == 2) or cell2.id == 56 or cell2.id == 80)) then
		if cell.id == 15 then
			if cell.rot == 0 or cell.rot == 2 then
				SwapCells(x+1,y,0,x-1,y,2)
			end
		elseif cell.id == 56 then
			SwapCells(x+1,y,0,x-1,y,2)
		elseif cell.id == 80 then
			SwapCells(x+1,y,0,x-1,y,2)
		end
	end
end

function DoVMirror(x,y,cell)
	local cell1 = GetCell(x,y+1)
	local cell2 = GetCell(x,y-1)
	if not ((cell1.id == 15 and (cell1.rot == 1 or cell1.rot == 3) or cell1.id == 56 or cell1.id == 80)
	or (cell2.id == 15 and (cell2.rot == 1 or cell2.rot == 3) or cell2.id == 56 or cell2.id == 80)) then
		if cell.id == 15 then
			if cell.rot == 1 or cell.rot == 3 then
				SwapCells(x,y+1,1,x,y-1,3)
			end
		elseif cell.id == 56 then
			SwapCells(x,y+1,1,x,y-1,3)
		elseif cell.id == 80 then
			SwapCells(x,y+1,1,x,y-1,3)
		end
	end
end

function DoDMirror(x,y,cell)
	local cell1 = GetCell(x+1,y+1)
	local cell2 = GetCell(x-1,y-1)
	if cell1.id ~= 80 and cell2.id ~= 80 then
		SwapCells(x+1,y+1,0.5,x-1,y-1,2.5)
	end
	local cell1 = GetCell(x-1,y+1)
	local cell2 = GetCell(x+1,y-1)
	if cell1.id ~= 80 and cell2.id ~= 80 then
		SwapCells(x-1,y+1,1.5,x+1,y-1,3.5)
	end
end

function DoIntaker(x,y,cell,dir)
	if cell.id == 155 and (dir == 0 or dir == 2) then cell.hupdated = true
	elseif cell.id == 250 and (dir == 0 or dir == 3) then cell.firstupdated = true
	elseif cell.id == 251 and dir == 0 then cell.Rupdated = true
	elseif cell.id == 251 and dir == 2 then cell.Lupdated = true
	elseif cell.id == 251 and dir == 3 then cell.Uupdated = true
	else cell.updated = true end
	if dir == 0 then x = x + 1 elseif dir == 2 then x = x - 1
	elseif dir == 1 then y = y + 1 elseif dir == 3 then y = y - 1 end
	PullCell(x,y,(dir+2)%4,{force=1,noupdate=true})
end

function DoShifter(x,y,cell,dir)
	if cell.id ~= 107 or dir == 1 or dir == 3 then cell.updated = true
	else cell.hupdated = true end
	local cx,cy,cdir,c = x,y,dir
	if cell.id == 254 or cell.id == 260 then cx,cy,cdir,c = NextCell(x,y,(dir+1)%4)
	elseif cell.id == 255 or cell.id == 261 then cx,cy,cdir,c = NextCell(x,y,(dir-1)%4)
	else cx,cy,cdir,c = NextCell(x,y,(dir+2)%4) end
	if cx then
		local cell2 = GetCell(cx,cy)
		local gencell = table.copy(cell2)
		gencell.rot = (gencell.rot-c.rot)%4
		if not IsNonexistant(gencell,cdir,cx,cy) and CanMove(cell2,(cdir+2)%4,cx,cy,"pull") then
			if cell.id == 254 then gencell.rot = (gencell.rot+1)%4
			elseif cell.id == 255 then gencell.rot = (gencell.rot+1)%4 end
			gencell.lastvars = table.copy(cell.lastvars)
			gencell.lastvars[3] = gencell.rot
			gencell = ToGenerate(gencell,cdir,cx,cy)
			if gencell then
				cell.eatencells = cell.eatencells or {}
				SetCell(cx,cy,getempty())
				if cdir == 0 then cx = cx + 1 elseif cdir == 2 then cx = cx - 1
				elseif cdir == 1 then cy = cy + 1 elseif cdir == 3 then cy = cy - 1 end
				local vars = {force=1,noupdate=true,dontfailonfirst=true}
				if not PullCell(cx,cy,(cdir+2)%4,vars) then
					if cdir == 2 then cx = cx + 1 elseif cdir == 0 then cx = cx - 1
					elseif cdir == 3 then cy = cy + 1 elseif cdir == 1 then cy = cy - 1 end
					SetCell(cx,cy,cell2)
					return
				end
				local success = false
				if cell.id ~= 256 and cell.id ~= 262 then
					local ccx,ccy = x,y
					if dir == 0 then ccx = x + 1 elseif dir == 2 then ccx = x - 1
					elseif dir == 1 then ccy = y + 1 elseif dir == 3 then ccy = y - 1 end
					success = PushCell(ccx,ccy,dir,{replacecell=gencell,force=1}) or success
				end
				if cell.id == 256 or cell.id == 257 or cell.id == 258 or cell.id == 262 or cell.id == 263 or cell.id == 264 then
					local dir = (dir - 1)%4
					local ccx,ccy = x,y
					if dir == 0 then ccx = x + 1 elseif dir == 2 then ccx = x - 1
					elseif dir == 1 then ccy = y + 1 elseif dir == 3 then ccy = y - 1 end
					local gencell = table.copy(gencell)
					if cell.id == 256 or cell.id == 257 or cell.id == 258 then
						gencell.rot = (gencell.rot-1)%4
					end
					success = PushCell(ccx,ccy,dir,{replacecell=gencell,force=1}) or success
				end
				if cell.id == 256 or cell.id == 257 or cell.id == 259 or cell.id == 262 or cell.id == 263 or cell.id == 265 then
					local dir = (dir + 1)%4
					local ccx,ccy = x,y
					if dir == 0 then ccx = x + 1 elseif dir == 2 then ccx = x - 1
					elseif dir == 1 then ccy = y + 1 elseif dir == 3 then ccy = y - 1 end
					local gencell = table.copy(gencell)
					if cell.id == 256 or cell.id == 257 or cell.id == 259 then
						gencell.rot = (gencell.rot+1)%4
					end
					success = PushCell(ccx,ccy,dir,{replacecell=gencell,force=1}) or success
				end
				if not success then
					for k,v in pairs(vars.undocells) do
						SetCell(k%width,math.floor(k/width),v)
					end
					if cdir == 2 then cx = cx + 1 elseif cdir == 0 then cx = cx - 1
					elseif cdir == 3 then cy = cy + 1 elseif cdir == 1 then cy = cy - 1 end
					SetCell(cx,cy,cell2)
				else
					table.insert(cell.eatencells,cell2)
				end
			end
		end
	end
end

function DoCreator(x,y,cell)
	if cell.vars[1] then
		for i=0,3 do
			local cx,cy = x,y
			if i == 0 then cx = cx + 1 elseif i == 2 then cx = cx - 1
			elseif i == 1 then cy = cy + 1 elseif i == 3 then cy = cy - 1 end
			PushCell(cx,cy,i,{replacecell={id=cell.vars[1],rot=cell.vars[2],lastvars={x,y,cell.vars[2]},vars={}},noupdate=true,force=1})
		end
	end
end

function DoMemory(x,y,cell)
	cell.updated = true
	local cx,cy,cdir,c = NextCell(x,y,(cell.rot+2)%4)
	if cx then
		local gencell = CopyCell(cx,cy)
		gencell.rot = (gencell.rot-c.rot)%4
		gencell = ToGenerate(gencell,cdir,cx,cy)
		if gencell then
			cell.vars[1] = gencell.id
			cell.vars[2] = gencell.rot
		end
	end
	if cell.vars[1] then
		local gencell = {id=cell.vars[1],rot=cell.vars[2],lastvars={x,y,cell.vars[2]},vars = DefaultVars(cell.vars[1])}
		gencell.lastvars = table.copy(cell.lastvars)
		gencell.lastvars[3] = gencell.rot
		if cell.rot == 0 then x = x + 1 elseif cell.rot == 2 then x = x - 1
		elseif cell.rot == 1 then y = y + 1 elseif cell.rot == 3 then y = y - 1 end
		PushCell(x,y,cell.rot,{replacecell=gencell,noupdate=true,force=1})
		--no optimizing here just so that memory will keep reading the cells behind them, even if they dont generate anything
	end
end

function DoSuperGenerator(x,y,cell)
	cell.updated = true
	local gencells = {}
	local cx,cy,cdir,c = x,y,(cell.rot+2)%4,getempty()
	while true do
		cx,cy,cdir = NextCell(cx,cy,cdir,c,true)	
		if cx then
			local gencell = CopyCell(cx,cy)
			gencell.rot = (gencell.rot-c.rot)%4
			gencell = ToGenerate(gencell,cell.rot,x,y)
			if gencell then
				gencell.lastvars = table.copy(cell.lastvars)
				gencell.lastvars[3] = gencell.rot
				table.insert(gencells,gencell)
			else
				break
			end
			local data = GetData(cx,cy)
			if data.updatekey == updatekey and data.crosses >= 5 then
				gencells = {}
				break
			else
				data.crosses = data.updatekey == updatekey and data.crosses + 1 or 1
			end
			data.updatekey = updatekey
		else
			gencells = {}
			break
		end
	end
	updatekey = updatekey + 1
	local cx,cy,cdir,c = x,y,cell.rot,getempty()
	for i=#gencells,1,-1 do
		cx,cy,cdir = NextCell(cx,cy,cdir,c)	
		if cx and not IsDestroyer(GetCell(cx,cy),cdir,cx,cy,{forcetype="push",lastcell=gencells[i] or cell,lastx=x,lasty=y}) then
			gencells[i].rot = (gencells[i].rot+c.rot)%4
			local a,b = PushCell(cx,cy,cdir,{replacecell=gencells[i],noupdate=true,force=1})
			if not a and b then
				updatekey = updatekey + 1
				local cx,cy = x,y
				while true do
					if cell.rot == 2 then cx = cx + 1 elseif cell.rot == 0 then cx = cx - 1
					elseif cell.rot == 3 then cy = cy + 1 elseif cell.rot == 1 then cy = cy - 1 end
					local newcell,gencell = GetCell(cx,cy)
					local genx,geny,gendir = NextCell(cx,cy,(newcell.rot+2)%4,c,true)
					if genx then
						gencell = CopyCell(genx,geny)
						NextCell(genx,geny,(gendir+2)%4,gencell)
					else gencell = getempty() end
					local nextx,nexty = NextCell(cx,cy,cell.rot,nil,false,true)
					if StopsOptimize(newcell,cell.rot,cx,cy,{forcetype="push",lastcell=gencell,lastx=cx,lasty=cy}) or (cell.rot == 1 or cell.rot == 3) and nextx ~= cx or (cell.rot == 0 or cell.rot == 2) and nexty ~= cy then
						break
					elseif newcell.id == 55 and newcell.rot == cell.rot then
						newcell.updated = true
					end
					local data = GetData(cx,cy)
					if data.updatekey == updatekey and data.crosses >= 5 then
						break
					else
						data.crosses = data.updatekey == updatekey and data.crosses + 1 or 1
					end
					data.updatekey = updatekey
				end
				break
			end
		else
			break
		end
	end
end

function DoGenerator(x,y,cell,dir)
	if (dir == 0 or dir == 2) and cell.id == 23 then cell.hupdated = true
	else cell.updated = true end
	if cell.id == 3 or cell.id == 23 or cell.id == 26 or cell.id == 27 or cell.id == 40 or cell.id == 113 or cell.id == 110 or cell.id == 111 or cell.id == 301 then
		local cx,cy,cdir,c
		if cell.id == 26 or cell.id == 110 then cx,cy,cdir,c = NextCell(x,y,(dir+1)%4,nil,true)
		elseif cell.id == 27 or cell.id == 111 then cx,cy,cdir,c = NextCell(x,y,(dir-1)%4,nil,true)
		else cx,cy,cdir,c = NextCell(x,y,(dir+2)%4,nil,true) end
		if cx then
			local gencell = CopyCell(cx,cy)
			gencell.rot = (gencell.rot-c.rot)%4
			gencell = ToGenerate(gencell,dir,x,y)
			if gencell then
				if cell.id == 26 then gencell.rot = (gencell.rot+1)%4
				elseif cell.id == 27 then gencell.rot = (gencell.rot-1)%4 end
				if cell.id == 40 then FlipCellRaw(gencell,(cell.rot+1)%2)
				elseif cell.id == 113 then gencell.rot = dir end
				gencell.lastvars = table.copy(cell.lastvars)
				gencell.lastvars[3] = gencell.rot
				if cell.id == 301 then
					SetCell(x,y,getempty())
					if fancy then GetCell(x,y).eatencells = {cell} end
				end
				if dir == 0 then x = x + 1 elseif dir == 2 then x = x - 1
				elseif dir == 1 then y = y + 1 elseif dir == 3 then y = y - 1 end
				local a,b = PushCell(x,y,dir,{replacecell=gencell,noupdate=true,force=1})
				if not a and cell.id == 301 then
					if dir == 2 then x = x + 1 elseif dir == 0 then x = x - 1
					elseif dir == 3 then y = y + 1 elseif dir == 1 then y = y - 1 end
					SetCell(x,y,cell)
				end
				if not a and b then
					updatekey = updatekey + 1
					local cx,cy = x,y
					while true do
						if dir == 2 then cx = cx + 1 elseif dir == 0 then cx = cx - 1
						elseif dir == 3 then cy = cy + 1 elseif dir == 1 then cy = cy - 1 end
						local newcell,gencell = GetCell(cx,cy)
						local genx,geny,gendir,c
						if newcell.rot == dir then
							if newcell.id == 26 or newcell.id == 110 then
								genx,geny,gendir,c = NextCell(cx,cy,(newcell.rot+1)%4)
							elseif newcell.id == 27 or newcell.id == 111 then
								genx,geny,gendir,c = NextCell(cx,cy,(newcell.rot-1)%4)
							else
								genx,geny,gendir,c = NextCell(cx,cy,(newcell.rot+2)%4)
							end
						end
						if genx then
							gencell = CopyCell(genx,geny)
							gencell.rot = (gencell.rot-c.rot)%4
						else gencell = getempty() end
						if newcell.id == 40 then FlipCellRaw(gencell,(cell.rot+1)%2) end
						local nextx,nexty = NextCell(cx,cy,dir)
						if StopsOptimize(newcell,dir,cx,cy,{forcetype="push",lastcell=gencell,lastx=cx,lasty=cy}) or (dir == 0 or dir == 2) and nexty ~= cy or (dir == 1 or dir == 3) and nextx ~= cx then
							break
						elseif (newcell.id == 3 or newcell.id == 26 or newcell.id == 27 or newcell.id == 110 or newcell.id == 111 or newcell.id == 301) and newcell.rot == dir then
							newcell.updated = true
						elseif newcell.id == 23 and (newcell.rot == dir or newcell.rot == (dir+1)%4) then
							if dir == 0 or dir == 2 then newcell.hupdated = true
							else newcell.updated = true end
						end
						local data = GetData(cx,cy)
						if data.updatekey == updatekey and data.crosses >= 5 then
							break
						else
							data.crosses = data.updatekey == updatekey and data.crosses + 1 or 1
						end
						data.updatekey = updatekey
					end
				end
			end
		end
	elseif cell.id == 167 or cell.id == 171 then
		local cx,cy,cdir,c = NextCell(x,y,(cell.rot+2)%4,nil,true)
		if cx then
			local gencell = CopyCell(cx,cy)
			gencell.rot = (gencell.rot-c.rot)%4
			gencell = ToGenerate(gencell,dir,x,y)
			if gencell then
				cx,cy = x,y
				if cell.rot == 0 then cx = x + 1 elseif cell.rot == 2 then cx = x - 1
				elseif cell.rot == 1 then cy = y + 1 elseif cell.rot == 3 then cy = y - 1 end
				PushCell(cx,cy,cell.rot,{replacecell=table.copy(gencell),noupdate=true,force=1})
				if cell.id == 167 then gencell.rot = (gencell.rot - 1)%4 end
				cx,cy = x,y
				if cell.rot == 1 then cx = x + 1 elseif cell.rot == 3 then cx = x - 1
				elseif cell.rot == 2 then cy = y + 1 elseif cell.rot == 0 then cy = y - 1 end
				PushCell(cx,cy,(cell.rot-1)%4,{replacecell=table.copy(gencell),noupdate=true,force=1})
				if cell.id == 167 then gencell.rot = (gencell.rot + 2)%4 end
				cx,cy = x,y
				if cell.rot == 3 then cx = x + 1 elseif cell.rot == 1 then cx = x - 1
				elseif cell.rot == 0 then cy = y + 1 elseif cell.rot == 2 then cy = y - 1 end
				PushCell(cx,cy,(cell.rot+1)%4,{replacecell=table.copy(gencell),noupdate=true,force=1})
			end
		end
	elseif cell.id == 168 or cell.id == 172 then
		local cx,cy,cdir,c = NextCell(x,y,(cell.rot+2)%4,nil,true)
		if cx then
			local gencell = CopyCell(cx,cy)
			gencell.rot = (gencell.rot-c.rot)%4
			gencell = ToGenerate(gencell,dir,x,y)
			if gencell then
				if cell.id == 168 then gencell.rot = (gencell.rot - 1)%4 end
				cx,cy = x,y
				if cell.rot == 1 then cx = x + 1 elseif cell.rot == 3 then cx = x - 1
				elseif cell.rot == 2 then cy = y + 1 elseif cell.rot == 0 then cy = y - 1 end
				PushCell(cx,cy,(cell.rot-1)%4,{replacecell=table.copy(gencell),noupdate=true,force=1})
				if cell.id == 168 then gencell.rot = (gencell.rot + 2)%4 end
				cx,cy = x,y
				if cell.rot == 3 then cx = x + 1 elseif cell.rot == 1 then cx = x - 1
				elseif cell.rot == 0 then cy = y + 1 elseif cell.rot == 2 then cy = y - 1 end
				PushCell(cx,cy,(cell.rot+1)%4,{replacecell=table.copy(gencell),noupdate=true,force=1})
			end
		end
	elseif cell.id == 169 or cell.id == 173 then
		local cx,cy,cdir,c = NextCell(x,y,(cell.rot+2)%4,nil,true)
		if cx then
			local gencell = CopyCell(cx,cy)
			gencell.rot = (gencell.rot-c.rot)%4
			gencell = ToGenerate(gencell,dir,x,y)
			if gencell then
				cx,cy = x,y
				if cell.rot == 0 then cx = x + 1 elseif cell.rot == 2 then cx = x - 1
				elseif cell.rot == 1 then cy = y + 1 elseif cell.rot == 3 then cy = y - 1 end
				PushCell(cx,cy,cell.rot,{replacecell=table.copy(gencell),noupdate=true,force=1})
				if cell.id == 169 then gencell.rot = (gencell.rot + 1)%4 end
				cx,cy = x,y
				if cell.rot == 3 then cx = x + 1 elseif cell.rot == 1 then cx = x - 1
				elseif cell.rot == 0 then cy = y + 1 elseif cell.rot == 2 then cy = y - 1 end
				PushCell(cx,cy,(cell.rot+1)%4,{replacecell=table.copy(gencell),noupdate=true,force=1})
			end
		end
	elseif cell.id == 170 or cell.id == 174 then
		local cx,cy,cdir,c = NextCell(x,y,(cell.rot+2)%4,nil,true)
		if cx then
			local gencell = CopyCell(cx,cy)
			gencell.rot = (gencell.rot-c.rot)%4
			gencell = ToGenerate(gencell,dir,x,y)
			if gencell then
				cx,cy = x,y
				if cell.rot == 0 then cx = x + 1 elseif cell.rot == 2 then cx = x - 1
				elseif cell.rot == 1 then cy = y + 1 elseif cell.rot == 3 then cy = y - 1 end
				PushCell(cx,cy,cell.rot,{replacecell=table.copy(gencell),noupdate=true,force=1})
				if cell.id == 170 then gencell.rot = (gencell.rot - 1)%4 end
				cx,cy = x,y
				if cell.rot == 1 then cx = x + 1 elseif cell.rot == 3 then cx = x - 1
				elseif cell.rot == 2 then cy = y + 1 elseif cell.rot == 0 then cy = y - 1 end
				PushCell(cx,cy,(cell.rot-1)%4,{replacecell=table.copy(gencell),noupdate=true,force=1})
			end
		end
	end
end

function DoSuperReplicator(x,y,cell)
	cell.updated = true
	local gencells = {}
	local cx,cy,cdir = x,y,cell.rot
	cell.testvar = "A"
	while true do
		cx,cy,cdir = NextCell(cx,cy,cdir,nil,nil,nil,true)
		if cx then
			local gencell = CopyCell(cx,cy)
			gencell = ToGenerate(gencell,cell.rot,x,y)
			if gencell then
				gencell.lastvars = table.copy(cell.lastvars)
				gencell.lastvars[3] = gencell.rot
				table.insert(gencells,gencell)
			else
				break
			end
			local data = GetData(cx,cy)
			if data.updatekey == updatekey and data.crosses >= 5 then
				gencells = {}
				break
			else
				data.crosses = data.updatekey == updatekey and data.crosses + 1 or 1
			end
			data.updatekey = updatekey
		else
			gencells = {}
			break
		end
	end
	updatekey = updatekey + 1
	local cx,cy,cdir,addedrot = x,y,cell.rot,0
	for i=1,#gencells do
		cx,cy,cdir = NextCell(cx,cy,cdir,nil,nil,nil,true)	
		if cx and not IsDestroyer(GetCell(cx,cy),cdir,cx,cy,{forcetype="push",lastcell=gencells[i] or cell,lastx=x,lasty=y}) then
			local a,b = PushCell(cx,cy,cdir,{replacecell=gencells[i],noupdate=true,force=1})
			if not a and b then
				local cx,cy = x,y
				while true do 
					if cell.rot == 2 then cx = cx + 1 elseif cell.rot == 0 then cx = cx - 1
					elseif cell.rot == 3 then cy = cy + 1 elseif cell.rot == 1 then cy = cy - 1 end
					local newcell = GetCell(cx,cy)
					local gencell = GetCell(cx+(rot == 0 and 1 or rot == 2 and -1 or 0),cy+(rot == 1 and 1 or rot == 3 and -1 or 0))
					local nextx,nexty = NextCell(cx,cy,cell.rot,nil,false,true)
					if StopsOptimize(newcell,cell.rot,cx,cy,{forcetype="push",lastcell=getempty(),lastx=cx,lasty=cy}) or (cell.rot == 1 or cell.rot == 3) and nextx ~= cx or (cell.rot == 0 or cell.rot == 2) and nexty ~= cy then
						break
					elseif newcell.id == 177 and newcell.rot == cell.rot then
						newcell.updated = true
					end
					local data = GetData(cx,cy)
					if data.updatekey == updatekey and data.crosses >= 5 then
						gencells = {}
						break
					else
						data.crosses = data.updatekey == updatekey and data.crosses + 1 or 1
					end
					data.updatekey = updatekey
				end
				updatekey = updatekey + 1
				break
			end
		else
			break
		end
	end
end

function DoReplicator(x,y,cell,dir)
	if cell.id ~= 46 or dir == 1 or dir == 3 then cell.updated = true
	else cell.hupdated = true end
	local cx,cy,cdir = NextCell(x,y,dir)
	if cx then
		local gencell = ToGenerate(CopyCell(cx,cy),dir,x,y)
		if gencell then
			gencell.lastvars = table.copy(cell.lastvars)
			gencell.lastvars[3] = gencell.rot
			if cell.id == 302 then
				SetCell(x,y,getempty())
				if fancy then GetCell(x,y).eatencells = {cell} end
			end
			local a,b = PushCell(cx,cy,cdir,{replacecell=gencell,noupdate=true,force=1})
			if not a and cell.id == 302 then
				SetCell(x,y,cell)
			end
			if not a and b and not StopsOptimize(gencell,dir,cx,cy,{forcetype="push"}) then
				local cx,cy = x,y
				while true do
					if dir == 2 then cx = cx + 1 elseif dir == 0 then cx = cx - 1
					elseif dir == 3 then cy = cy + 1 elseif dir == 1 then cy = cy - 1 end
					local newcell = GetCell(cx,cy)
					local gencell = GetCell(cx+(dir == 0 and 1 or dir == 2 and -1 or 0),cy+(dir == 1 and 1 or dir == 3 and -1 or 0))
					local nextx,nexty = NextCell(cx,cy,dir,nil,false,true)
					if StopsOptimize(newcell,dir,cx,cy,{forcetype="push",lastcell=gencell,lastx=cx,lasty=cy}) or (dir == 0 or dir == 2) and nexty ~= cy or (dir == 1 or dir == 3) and nextx ~= cx then
						break
					elseif (newcell.id == 45 or newcell.id == 302) and newcell.rot == dir then
						newcell.updated = true
					elseif newcell.id == 46 and (newcell.rot == dir or newcell.rot == (dir+1)%4) then
						if dir == 0 or dir == 2 then newcell.hupdated = true
						else newcell.updated = true end
					end
					local data = GetData(cx,cy)
					if data.updatekey == updatekey and data.crosses >= 5 then
						break
					else
						data.crosses = data.updatekey == updatekey and data.crosses + 1 or 1
					end
					data.updatekey = updatekey
				end
				updatekey = updatekey + 1
			end
		end
	end
end

function DoFlipper(x,y,cell)
	local neighbors = GetNeighbors(x,y)
	if cell.id == 30 then
		for k,v in pairs(neighbors) do
			FlipCell(v[1],v[2],cell.rot,k)
		end
	elseif cell.id == 89 then
		if cell.rot == 0 or cell.rot == 2 then
			FlipCell(neighbors[2][1],neighbors[2][2],0,2)
			FlipCell(neighbors[0][1],neighbors[0][2],0,0)
		else
			FlipCell(neighbors[1][1],neighbors[1][2],1,1)
			FlipCell(neighbors[3][1],neighbors[3][2],1,3)
		end
	elseif cell.id == 90 then
		if cell.rot == 0 or cell.rot == 2 then
			FlipCell(neighbors[1][1],neighbors[1][2],0,1)
			FlipCell(neighbors[3][1],neighbors[3][2],0,3)
		else
			FlipCell(neighbors[0][1],neighbors[0][2],1,0)
			FlipCell(neighbors[2][1],neighbors[2][2],1,2)
		end
	end
end

function DoRotator(x,y,cell)
	local neighbors = GetNeighbors(x,y)
	if cell.id == 9 then
		for k,v in pairs(neighbors) do
			RotateCell(v[1],v[2],1,k)
		end
	elseif cell.id == 10 then
		for k,v in pairs(neighbors) do
			RotateCell(v[1],v[2],-1,k)
		end
	elseif cell.id == 11 then
		for k,v in pairs(neighbors) do
			RotateCell(v[1],v[2],2,k)
		end
	elseif cell.id == 66 then
		if cell.rot == 0 or cell.rot == 2 then
			RotateCell(neighbors[2][1],neighbors[2][2],1,2)
			RotateCell(neighbors[0][1],neighbors[0][2],1,0)
		else
			RotateCell(neighbors[1][1],neighbors[1][2],1,1)
			RotateCell(neighbors[3][1],neighbors[3][2],1,3)
		end
	elseif cell.id == 67 then
		if cell.rot == 0 or cell.rot == 2 then
			RotateCell(neighbors[2][1],neighbors[2][2],-1,2)
			RotateCell(neighbors[0][1],neighbors[0][2],-1,0)
		else
			RotateCell(neighbors[1][1],neighbors[1][2],-1,1)
			RotateCell(neighbors[3][1],neighbors[3][2],-1,3)
		end
	elseif cell.id == 68 then
		if cell.rot == 0 or cell.rot == 2 then
			RotateCell(neighbors[2][1],neighbors[2][2],2,2)
			RotateCell(neighbors[0][1],neighbors[0][2],2,0)
		else
			RotateCell(neighbors[1][1],neighbors[1][2],2,1)
			RotateCell(neighbors[3][1],neighbors[3][2],2,3)
		end
	elseif cell.id == 57 then
		if cell.rot == 0 then
			RotateCell(neighbors[0][1],neighbors[0][2],1,0)
			RotateCell(neighbors[1][1],neighbors[1][2],1,1)
			RotateCell(neighbors[2][1],neighbors[2][2],-1,2)
			RotateCell(neighbors[3][1],neighbors[3][2],-1,3)
		elseif cell.rot == 1 then
			RotateCell(neighbors[0][1],neighbors[0][2],-1,0)
			RotateCell(neighbors[1][1],neighbors[1][2],1,1)
			RotateCell(neighbors[2][1],neighbors[2][2],1,2)
			RotateCell(neighbors[3][1],neighbors[3][2],-1,3)
		elseif cell.rot == 2 then
			RotateCell(neighbors[0][1],neighbors[0][2],-1,0)
			RotateCell(neighbors[1][1],neighbors[1][2],-1,1)
			RotateCell(neighbors[2][1],neighbors[2][2],1,2)
			RotateCell(neighbors[3][1],neighbors[3][2],1,3)
		else
			RotateCell(neighbors[0][1],neighbors[0][2],1,0)
			RotateCell(neighbors[1][1],neighbors[1][2],-1,1)
			RotateCell(neighbors[2][1],neighbors[2][2],-1,2)
			RotateCell(neighbors[3][1],neighbors[3][2],1,3)
		end
	elseif cell.id == 70 then
		if cell.rot == 0 or cell.rot == 2 then
			RotateCell(neighbors[0][1],neighbors[0][2],1,0)
			RotateCell(neighbors[1][1],neighbors[1][2],-1,1)
			RotateCell(neighbors[2][1],neighbors[2][2],1,2)
			RotateCell(neighbors[3][1],neighbors[3][2],-1,3)
		else
			RotateCell(neighbors[0][1],neighbors[0][2],-1,0)
			RotateCell(neighbors[1][1],neighbors[1][2],1,1)
			RotateCell(neighbors[2][1],neighbors[2][2],-1,2)
			RotateCell(neighbors[3][1],neighbors[3][2],1,3)
		end
	elseif cell.id == 245 then
		local neighbors = GetSurrounding(x,y)
		for k,v in pairs(neighbors) do
			RotateCell(v[1],v[2],1,k,true)
		end
	elseif cell.id == 246 then
		local neighbors = GetSurrounding(x,y)
		for k,v in pairs(neighbors) do
			RotateCell(v[1],v[2],-1,k,true)
		end
	elseif cell.id == 247 then
		local neighbors = GetSurrounding(x,y)
		for k,v in pairs(neighbors) do
			RotateCell(v[1],v[2],2,k,true)
		end
	end
end

function DoGear(x,y,cell)
	if cell.id == 18 then
		local neighbors = GetSurrounding(x,y)
		local jammed
		for k,v in pairs(neighbors) do
			jammed = jammed or IsUnbreakable(GetCell(v[1],v[2]),k,v[1],v[2],{forcetype="swap",lastcell=cell}) or ConvertId(GetCell(v[1],v[2]).id) == 18 or ConvertId(GetCell(v[1],v[2]).id) == 19
		end
		if not jammed then
			RotateCell(neighbors[0.5][1],neighbors[0.5][2],1,0.5)
			RotateCell(neighbors[1.5][1],neighbors[1.5][2],1,1.5)
			RotateCell(neighbors[2.5][1],neighbors[2.5][2],1,2.5)
			RotateCell(neighbors[3.5][1],neighbors[3.5][2],1,3.5)
			local lastcell = getempty()
			for i=0,3.5,.5 do
				local v = neighbors[i]
				local cell = CopyCell(v[1],v[2])
				SetCell(v[1],v[2],lastcell)
				lastcell = cell
			end
			local v = neighbors[0]
			local cell = CopyCell(v[1],v[2])
			SetCell(v[1],v[2],lastcell)
			Play(movesound)
		end
	elseif cell.id == 19 then
		local neighbors = GetSurrounding(x,y)
		local jammed
		for k,v in pairs(neighbors) do
			jammed = jammed or IsUnbreakable(GetCell(v[1],v[2]),k,v[1],v[2],{forcetype="swap",lastcell=cell}) or ConvertId(GetCell(v[1],v[2]).id) == 18 or ConvertId(GetCell(v[1],v[2]).id) == 19
		end
		if not jammed then
			RotateCell(neighbors[0.5][1],neighbors[0.5][2],-1,0.5)
			RotateCell(neighbors[1.5][1],neighbors[1.5][2],-1,1.5)
			RotateCell(neighbors[2.5][1],neighbors[2.5][2],-1,2.5)
			RotateCell(neighbors[3.5][1],neighbors[3.5][2],-1,3.5)
			local lastcell = getempty()
			for i=3.5,0,-.5 do
				local v = neighbors[i]
				local cell = CopyCell(v[1],v[2])
				SetCell(v[1],v[2],lastcell)
				lastcell = cell
			end
			local v = neighbors[3.5]
			local cell = CopyCell(v[1],v[2])
			SetCell(v[1],v[2],lastcell)
			Play(movesound)
		end
	elseif cell.id == 108 then
		local neighbors = GetNeighbors(x,y)
		local jammed
		for k,v in pairs(neighbors) do
			jammed = jammed or IsUnbreakable(GetCell(v[1],v[2]),k,v[1],v[2],{forcetype="swap",lastcell=cell}) or ConvertId(GetCell(v[1],v[2]).id) == 18 or ConvertId(GetCell(v[1],v[2]).id) == 19
		end
		if not jammed then
			RotateCell(neighbors[0][1],neighbors[0][2],1,0)
			RotateCell(neighbors[1][1],neighbors[1][2],1,1)
			RotateCell(neighbors[2][1],neighbors[2][2],1,2)
			RotateCell(neighbors[3][1],neighbors[3][2],1,3)
			local lastcell = getempty()
			for i=0,3 do
				local v = neighbors[i]
				local cell = CopyCell(v[1],v[2])
				SetCell(v[1],v[2],lastcell)
				lastcell = cell
			end
			local v = neighbors[0]
			local cell = CopyCell(v[1],v[2])
			SetCell(v[1],v[2],lastcell)
			Play(movesound)
		end
	elseif cell.id == 109 then
		local neighbors = GetNeighbors(x,y)
		local jammed
		for k,v in pairs(neighbors) do
			jammed = jammed or IsUnbreakable(GetCell(v[1],v[2]),k,v[1],v[2],{forcetype="swap",lastcell=cell}) or ConvertId(GetCell(v[1],v[2]).id) == 18 or ConvertId(GetCell(v[1],v[2]).id) == 19
		end
		if not jammed then
			RotateCell(neighbors[0][1],neighbors[0][2],-1,0)
			RotateCell(neighbors[1][1],neighbors[1][2],-1,1)
			RotateCell(neighbors[2][1],neighbors[2][2],-1,2)
			RotateCell(neighbors[3][1],neighbors[3][2],-1,3)
			local lastcell = getempty()
			for i=3,0,-1 do
				local v = neighbors[i]
				local cell = CopyCell(v[1],v[2])
				SetCell(v[1],v[2],lastcell)
				lastcell = cell
			end
			local v = neighbors[3]
			local cell = CopyCell(v[1],v[2])
			SetCell(v[1],v[2],lastcell)
			Play(movesound)
		end
	end
end

function DoRedirector(x,y,cell)
	local neighbors = GetNeighbors(x,y)
	if cell.id == 17 then
		for k,v in pairs(neighbors) do
			RotateCellTo(v[1],v[2],cell.rot,k)
		end
	elseif cell.id == 62 then
		for k,v in pairs(neighbors) do
			RotateCellTo(v[1],v[2],k,k)
		end
	elseif cell.id == 63 then
		for k,v in pairs(neighbors) do
			RotateCellTo(v[1],v[2],(k+2)%4,k)
		end
	elseif cell.id == 64 then
		for k,v in pairs(neighbors) do
			RotateCellTo(v[1],v[2],(k+1)%4,k)
		end
	elseif cell.id == 65 then
		for k,v in pairs(neighbors) do
			RotateCellTo(v[1],v[2],(k-1)%4,k)
		end
	end
end

function DoInertia(x,y,cell,dir)
	if not PushCell(x,y,dir) then
		if dir == 0 or dir == 2 then
			GetCell(x,y).vars[1] = 0
		else
			GetCell(x,y).vars[2] = 0
		end
	end
end

function DoSuperImpulsor(x,y,dir)
	local cx,cy,cdir = x,y,(dir + 2)%4
	while true do
		cx,cy,cdir = NextCell(cx,cy,cdir,nil,true)
		if cx then
			if not IsTransparent(GetCell(cx,cy),(cdir + 2)%4,cx,cy,{forcetype="nudge",lastcell=GetCell(cx,cy)}) then
				break
			end
			local data = GetData(cx,cy)
			if data.updatekey == updatekey and data.crosses >= 5 then
				break
			else
				data.crosses = data.updatekey == updatekey and data.crosses + 1 or 1
			end
			data.updatekey = updatekey
		else break end
	end
	updatekey = updatekey + 1
	if cx then
		cdir = (cdir + 2)%4
	end
	while true do
		if cx then
			if IsTransparent(GetCell(cx,cy),(cdir + 2)%4,cx,cy,{forcetype="nudge",lastcell=GetCell(cx,cy)}) or not PullCell(cx,cy,cdir,{force=math.huge}) then
				break
			end
			local data = GetData(cx,cy)
			if data.supdatekey == supdatekey and data.scrosses >= 5 then
				break
			else
				data.scrosses = data.supdatekey == supdatekey and data.scrosses + 1 or 1
			end
			data.supdatekey = supdatekey
		else break end
		cx,cy,cdir = NextCell(cx,cy,cdir)
	end
	supdatekey = supdatekey + 1
end

function DoImpulsor(x,y,dir)
	dir = (dir+2)%4
	local x,y,dir = NextCell(x,y,dir,nil,true)
	local cx,cy = x,y
	if dir == 0 then cx = x + 1 elseif dir == 2 then cx = x - 1
	elseif dir == 1 then cy = y + 1 elseif dir == 3 then cy = y - 1 end
	local checkedcell = GetCell(x,y)
	PullCell(cx,cy,(dir+2)%4,{force=1,noupdate=true})
end

function DoGrapulsor(x,y,cell,dir)
	if cell.id == 227 or cell.id == 228 then
		if dir == 3 then x = x + 1 elseif dir == 1 then x = x - 1
		elseif dir == 0 then y = y + 1 elseif dir == 2 then y = y - 1 end
		RGraspCell(x,y,dir,{force=1,noupdate=true})
		if dir == 1 then x = x + 2 elseif dir == 3 then x = x - 2
		elseif dir == 2 then y = y + 2 elseif dir == 0 then y = y - 2 end
		LGraspCell(x,y,dir,{force=1,noupdate=true})
	else
		if cell.id == 81 then dir = (dir-1)%4 else dir = (dir+1)%4 end
		if dir == 0 then x = x + 1 elseif dir == 2 then x = x - 1
		elseif dir == 1 then y = y + 1 elseif dir == 3 then y = y - 1 end
		if cell.id == 81 then
			LGraspCell(x,y,(dir+1)%4,{force=1,noupdate=true})
		else
			RGraspCell(x,y,(dir-1)%4,{force=1,noupdate=true})
		end
	end
end

function DoSuperRepulsor(x,y,dir)
	local cx,cy,cdir = NextCell(x,y,dir)
	while true do
		local nextx,nexty,nextdir = NextCell(cx,cy,cdir)
		if IsTransparent(GetCell(cx,cy),cdir,cx,cy,{forcetype="push",lastcell=GetCell(cx,cy)}) or not PushCell(cx,cy,cdir,{force=math.huge,noupdate=true}) then
			break
		end
		local data = GetData(cx,cy)
		if data.supdatekey == supdatekey and data.scrosses >= 5 then
			break
		else
			data.scrosses = data.supdatekey == supdatekey and data.scrosses + 1 or 1
		end
		data.supdatekey = supdatekey
		if not nextx then break end
		cx,cy,cdir = nextx,nexty,nextdir
	end
	supdatekey = supdatekey + 1
end

function DoTimeRepulsor(x,y,dir)
	for i=0,3 do
		local cx,cy,cdir = NextCell(x,y,i)
		local cell = GetCell(cx,cy)
		cell.vars[cdir==0 and "timerepulseright" or cdir==2 and "timerepulseleft" or cdir==3 and "timerepulseup" or "timerepulsedown"] = 1
		SetChunkId(x,y,"timerep")
	end
end

function DoRepulsor(x,y,dir)
	if dir == 0 then x = x + 1 elseif dir == 2 then x = x - 1
	elseif dir == 1 then y = y + 1 elseif dir == 3 then y = y - 1 end
	PushCell(x,y,dir,{force=1,noupdate=true})
end

function DoMagnet(x,y,cell)
	cell.updated = true
	local cx,cy,cdir = x,y,cell.rot
	if cell.rot == 0 then cx = x + 1 elseif cell.rot == 2 then cx = x - 1
	elseif cell.rot == 1 then cy = y + 1 elseif cell.rot == 3 then cy = y - 1 end
	if GetCell(cx,cy).id == 156 and GetCell(cx,cy).rot == (cell.rot+2)%4 then
		PushCell(cx,cy,cell.rot,{force=1,noupdate=true})
	elseif IsNonexistant(GetCell(cx,cy),cell.rot,cx,cy) then
		local cx,cy,cdir = NextCell(cx,cy,cell.rot,0,true,true)
		if cx and GetCell(cx,cy).id == 156 and GetCell(cx,cy).rot == cell.rot then
			PullCell(cx,cy,(cdir+2)%4,{force=1,noupdate=true})
		end
	end
	if GetCell(x,y) == cell then
		local cx,cy,cdir = x,y,cell.rot
		if cell.rot == 0 then cx = x - 1 elseif cell.rot == 2 then cx = x + 1
		elseif cell.rot == 1 then cy = y - 1 elseif cell.rot == 3 then cy = y + 1 end
		if GetCell(cx,cy).id == 156 and GetCell(cx,cy).rot == (cell.rot+2)%4 then
			PushCell(cx,cy,(cell.rot+2)%4,{force=1,noupdate=true})
		elseif IsNonexistant(GetCell(cx,cy),cell.rot,cx,cy) then
			local cx,cy,cdir = NextCell(cx,cy,(cell.rot+2)%4,0,true,true)
			if cx and GetCell(cx,cy).id == 156 and GetCell(cx,cy).rot == cell.rot then
				PullCell(cx,cy,(cdir+2)%4,{force=1,noupdate=true})
			end
		end
	end
end

function DoTermite(x,y,cell)
	cell.updated = true
	if cell.id == 306 then
		cell.rot = (cell.rot+1)%4
		for i=1,4 do
			if not PushCell(x,y,cell.rot,{force=1,noupdate=true}) and GetCell(x,y).id == 306 then
				cell.rot = (cell.rot-1)%4
			end
		end
	elseif cell.id == 307 then
		cell.rot = (cell.rot-1)%4
		for i=1,4 do
			if not PushCell(x,y,(cell.rot+2)%4,{force=1,noupdate=true}) and GetCell(x,y).id == 307 then
				cell.rot = (cell.rot+1)%4
			end
		end
	end
end

function SliceCell(x,y,dir,vars)
	local cell = GetCell(x,y)
	if not NudgeCell(x,y,dir) then
		local cx,cy = x,y
		if dir == 0 then cx = x + 1 elseif dir == 2 then cx = x - 1
		elseif dir == 1 then cy = y + 1 elseif dir == 3 then cy = y - 1 end
		local cdir = (dir == 0 or dir == 2) and 3 or 0
		if not IsUnbreakable(GetCell(cx,cy),dir,cx,cy,{forcetype="slice",lastcell=cell}) and PushCell(cx,cy,cdir,{force=1}) then
			if GetCell(x,y) == cell then return NudgeCell(x,y,dir) end
		else
			if not IsUnbreakable(GetCell(cx,cy),dir,cx,cy,{forcetype="slice",lastcell=cell}) and PushCell(cx,cy,(cdir+2)%4,{force=1}) then
				if GetCell(x,y) == cell then return NudgeCell(x,y,dir) end
			end
		end
	else
		return true
	end
end


function DoDriller(x,y,cell)
	cell.updated = true
	local cx,cy,dir = x,y,cell.rot
	if dir == 0 then cx = x + 1 elseif dir == 2 then cx = x - 1
	elseif dir == 1 then cy = y + 1 elseif dir == 3 then cy = y - 1 end
	local ccx,ccy = x,y
	if dir == 0 then ccx = x - 1 elseif dir == 2 then ccx = x + 1
	elseif dir == 1 then ccy = y - 1 elseif dir == 3 then ccy = y + 1 end
	if cell.id == 58 then
		SwapCells(x,y,(dir+2)%4,cx,cy,dir)
	elseif cell.id == 59 then
		if not PushCell(x,y,dir) then 
			SwapCells(x,y,(dir+2)%4,cx,cy,dir)
		end
	elseif cell.id == 60 then
		if PushCell(x,y,dir) then
			PullCell(ccx,ccy,dir,{force=1})
		elseif not PullCell(x,y,dir) then
			SwapCells(x,y,(dir+2)%4,cx,cy,dir)
		end
	elseif cell.id == 61 then
		if not PullCell(x,y,dir) then
			SwapCells(x,y,(dir+2)%4,cx,cy,dir)
		end
	elseif cell.id == 75 then 
		if SwapCells(x,y,(dir+2)%4,cx,cy,dir) then
			GraspEmptyCell(x,y,dir,{force=1})
		else
			GraspCell(x,y,dir)
		end
	elseif cell.id == 76 then
		if PushCell(x,y,dir) then
			GraspEmptyCell(x,y,dir,{force=1})
		elseif SwapCells(x,y,(dir+2)%4,cx,cy,dir) then
			GraspEmptyCell(x,y,dir,{force=1})
		else
			GraspCell(x,y,dir)
		end
	elseif cell.id == 77 then
		if GraspCell(x,y,dir) then
			PullCell(ccx,ccy,dir,{force=1})
		elseif PullCell(x,y,dir) then
			GraspEmptyCell(x,y,dir,{force=1})
		elseif SwapCells(x,y,(dir+2)%4,cx,cy,dir) then
			GraspEmptyCell(x,y,dir,{force=1})
			PullCell(ccx,ccy,dir,{force=1})
		end
	elseif cell.id == 78 then
		if PushCell(x,y,dir) then
			GraspEmptyCell(x,y,dir,{force=1})
			PullCell(ccx,ccy,dir,{force=1})
		elseif SwapCells(x,y,(dir+2)%4,cx,cy,dir) then
			GraspEmptyCell(x,y,dir,{force=1})
			PullCell(ccx,ccy,dir,{force=1})
		elseif GraspCell(x,y,dir) then
			PullCell(ccx,ccy,dir,{force=1})
		else
			PullCell(x,y,dir)
		end
	elseif cell.id == 276 then
		if not SliceCell(x,y,cell.rot) then 
			SwapCells(x,y,(dir+2)%4,cx,cy,dir)
		end
	elseif cell.id == 277 then
		if not PushCell(x,y,cell.rot) then 
			if not SliceCell(x,y,cell.rot) then 
				SwapCells(x,y,(dir+2)%4,cx,cy,dir)
			end
		end
	elseif cell.id == 278 then
		if SliceCell(x,y,cell.rot) then 
			PullCell(ccx,ccy,cell.rot,{force=1})
		elseif SwapCells(x,y,(dir+2)%4,cx,cy,dir) then
			PullCell(ccx,ccy,cell.rot,{force=1})
		else
			PullCell(x,y,cell.rot)
		end
	elseif cell.id == 279 then
		if PushCell(x,y,cell.rot) then 
			PullCell(ccx,ccy,cell.rot,{force=1})
		elseif SliceCell(x,y,cell.rot) then 
			PullCell(ccx,ccy,cell.rot,{force=1})
		elseif SwapCells(x,y,(dir+2)%4,cx,cy,dir) then
			PullCell(ccx,ccy,cell.rot,{force=1})
		else
			PullCell(x,y,cell.rot)
		end
	elseif cell.id == 280 then
		if SliceCell(x,y,cell.rot) then 
			GraspEmptyCell(x,y,cell.rot,{force=1})
		elseif SwapCells(x,y,(dir+2)%4,cx,cy,dir) then
			GraspEmptyCell(x,y,cell.rot,{force=1})
		else
			GraspCell(x,y,cell.rot)
		end
	elseif cell.id == 281 then
		if PushCell(x,y,cell.rot) then 
			GraspEmptyCell(x,y,cell.rot,{force=1})
		elseif SliceCell(x,y,cell.rot) then 
			GraspEmptyCell(x,y,cell.rot,{force=1})
		elseif SwapCells(x,y,(dir+2)%4,cx,cy,dir) then
			GraspEmptyCell(x,y,cell.rot,{force=1})
		else
			GraspCell(x,y,cell.rot)
		end
	elseif cell.id == 282 then
		if SliceCell(x,y,cell.rot) then 
			GraspEmptyCell(x,y,cell.rot,{force=1})
			PullCell(ccx,ccy,cell.rot,{force=1})
		elseif SwapCells(x,y,(dir+2)%4,cx,cy,dir) then
			GraspEmptyCell(x,y,cell.rot,{force=1})
			PullCell(ccx,ccy,cell.rot,{force=1})
		elseif GraspCell(x,y,cell.rot) then 
			PullCell(ccx,ccy,cell.rot,{force=1})
		else
			PullCell(x,y,cell.rot)
		end
	elseif cell.id == 283 then
		if PushCell(x,y,cell.rot) then 
			GraspEmptyCell(x,y,cell.rot,{force=1})
			PullCell(ccx,ccy,cell.rot,{force=1})
		elseif SliceCell(x,y,cell.rot) then 
			GraspEmptyCell(x,y,cell.rot,{force=1})
			PullCell(ccx,ccy,cell.rot,{force=1})
		elseif SwapCells(x,y,(dir+2)%4,cx,cy,dir) then
			GraspEmptyCell(x,y,cell.rot,{force=1})
			PullCell(ccx,ccy,cell.rot,{force=1})
		elseif GraspCell(x,y,cell.rot) then 
			PullCell(ccx,ccy,cell.rot,{force=1})
		else
			PullCell(x,y,cell.rot)
		end
	end
end

function DoPuller(x,y,cell)
	cell.updated = true
	local cx,cy = x,y
	if cell.rot == 0 then cx = x - 1 elseif cell.rot == 2 then cx = x + 1
	elseif cell.rot == 1 then cy = y - 1 elseif cell.rot == 3 then cy = y + 1 end
	if cell.id == 14 then
		PullCell(x,y,cell.rot)
	elseif cell.id == 28 then
		if PushCell(x,y,cell.rot) then
			PullCell(cx,cy,cell.rot,{force=1})
		else
			PullCell(x,y,cell.rot)
		end
	elseif cell.id == 73 then
		if GraspCell(x,y,cell.rot) then
			PullCell(cx,cy,cell.rot,{force=1})
		elseif PullCell(x,y,cell.rot) then 
			GraspEmptyCell(x,y,cell.rot,{force=1})
		end
	elseif cell.id == 74 then
		if PushCell(x,y,cell.rot) then 
			GraspEmptyCell(x,y,cell.rot,{force=1})
			PullCell(cx,cy,cell.rot,{force=1})
		elseif GraspCell(x,y,cell.rot) then
			PullCell(cx,cy,cell.rot,{force=1})
		else
			PullCell(x,y,cell.rot,{force=1})
		end
	elseif cell.id == 270 then
		if SliceCell(x,y,cell.rot) then 
			PullCell(cx,cy,cell.rot,{force=1})
		else
			PullCell(x,y,cell.rot)
		end
	elseif cell.id == 271 then
		if PushCell(x,y,cell.rot) then 
			PullCell(cx,cy,cell.rot,{force=1})
		elseif SliceCell(x,y,cell.rot) then 
			PullCell(cx,cy,cell.rot,{force=1})
		else
			PullCell(x,y,cell.rot)
		end
	elseif cell.id == 274 then
		if SliceCell(x,y,cell.rot) then 
			GraspEmptyCell(x,y,cell.rot,{force=1})
			PullCell(cx,cy,cell.rot,{force=1})
		elseif GraspCell(x,y,cell.rot) then 
			PullCell(cx,cy,cell.rot,{force=1})
		else
			PullCell(x,y,cell.rot)
		end
	elseif cell.id == 275 then
		if PushCell(x,y,cell.rot) then 
			GraspEmptyCell(x,y,cell.rot,{force=1})
			PullCell(cx,cy,cell.rot,{force=1})
		elseif SliceCell(x,y,cell.rot) then 
			GraspEmptyCell(x,y,cell.rot,{force=1})
			PullCell(cx,cy,cell.rot,{force=1})
		elseif GraspCell(x,y,cell.rot) then 
			PullCell(cx,cy,cell.rot,{force=1})
		else
			PullCell(x,y,cell.rot)
		end
	elseif cell.id == 305 then
		local ccx,ccy = NextCell(x,y,cell.rot)
		if PullCell(x,y,cell.rot) and not IsTransparent(GetCell(x,y),cell.rot,x,y,{forcetype="pull",lastcell=cell}) then
			SetCell(ccx,ccy,getempty())
			if fancy then GetCell(ccx,ccy).eatencells = {cell} end
		end
	elseif cell.id == 311 then
		local v = {}
		if PushCell(x,y,cell.rot,v) then
			PullCell(cx,cy,cell.rot,{force=1,undocells=v.undocells})
		end
	end
end

function DoGrasper(x,y,cell)
	cell.updated = true
	if cell.id == 71 then
		GraspCell(x,y,cell.rot)
	elseif cell.id == 72 then
		if PushCell(x,y,cell.rot) then 
			GraspEmptyCell(x,y,cell.rot,{force=1})
		else
			GraspCell(x,y,cell.rot)
		end
	elseif cell.id == 272 then
		if SliceCell(x,y,cell.rot) then 
			GraspEmptyCell(x,y,cell.rot,{force=1})
		else
			GraspCell(x,y,cell.rot)
		end
	elseif cell.id == 273 then
		if PushCell(x,y,cell.rot) then 
			GraspEmptyCell(x,y,cell.rot,{force=1})
		elseif SliceCell(x,y,cell.rot) then 
			GraspEmptyCell(x,y,cell.rot,{force=1})
		else
			GraspCell(x,y,cell.rot)
		end
	end
end

function DoSuperPusher(x,y,cell)
	cell.updated = true
	local cx,cy,cdir = x,y,cell.rot
	while true do
		local nextx,nexty,nextdir = NextCell(cx,cy,cdir)
		if IsTransparent(GetCell(cx,cy),cdir,cx,cy,{forcetype="push",lastcell=GetCell(cx,cy)}) or not PushCell(cx,cy,cdir) then
			break
		end
		local data = GetData(cx,cy)
		if data.supdatekey == supdatekey and data.scrosses >= 5 then
			break
		else
			data.scrosses = data.supdatekey == supdatekey and data.scrosses + 1 or 1
		end
		data.supdatekey = supdatekey
		if not nextx then break end
		cx,cy,cdir = nextx,nexty,nextdir
	end
	supdatekey = supdatekey + 1
end

function DoPusher(x,y,cell)
	cell.updated = true
	if cell.id == 2 or cell.id == 213 then
		PushCell(x,y,cell.rot)
	elseif cell.id == 269 then
		if not PushCell(x,y,cell.rot) then
			SliceCell(x,y,cell.rot)
		end
	elseif cell.id == 303 then
		if not PushCell(x,y,cell.rot) then
			local cx,cy,cdir = NextCell(x,y,cell.rot)
			local cell2 = GetCell(cx,cy)
			if not IsUnbreakable(cell2,cdir,cx,cy,{forcetype="destroy",lastcell=cell}) then
				SetCell(cx,cy,getempty())
				if fancy then GetCell(x,y).eatencells = {cell2} end
			end
			PushCell(x,y,cell.rot)
		end
	elseif cell.id == 304 then
		local cx,cy,cdir = NextCell(x,y,cell.rot)
		local cell2 = GetCell(cx,cy)
		if IsTransparent(cell2,cdir,cx,cy,{forcetype="push",lastcell=cell}) then
			PushCell(x,y,cell.rot)
		else
			SetCell(x,y,getempty())
			PushCell(cx,cy,cdir,{force=1,undocells={[x+y*width] = cell},replacecell={id=0,rot=0,lastvars={x,y,0},vars={},eatencells={cell}}})
		end
	end
end

function DoSlicer(x,y,cell)
	cell.updated = true
	if cell.id == 115 then
		SliceCell(x,y,cell.rot)
	end
end

function getAct(num,x,y,dir)
	if num == 0 then return PushCell(x,y,dir)
	elseif num == 1 then if PushCell(x,y,dir) then 
							GraspEmptyCell(x,y,dir,{force=1})
							return true
						else return GraspCell(x,y,dir) end
	elseif num == 2 then if PushCell(x,y,dir)  then
							if dir == 0 then x = x - 1 elseif dir == 2 then x = x + 1
							elseif dir == 1 then y = y - 1 elseif dir == 3 then y = y + 1 end
							PullCell(x,y,dir,{force=1})
							return true
						else
							return PullCell(x,y,dir)
						end
	elseif num == 3 then if dir == 0 then if not PushCell(x,y,0) then return SwapCells(x,y,2,x+1,y,0) else return true end
						elseif dir == 2 then if not PushCell(x,y,2) then return SwapCells(x,y,0,x-1,y,2) else return true end
						elseif dir == 3 then if not PushCell(x,y,3) then return SwapCells(x,y,1,x,y-1,3) else return true end
						elseif dir == 1 then if not PushCell(x,y,1) then return SwapCells(x,y,3,x,y+1,1) else return true end end
	elseif num == 4 then return PushCell(x,y,dir) or SliceCell(x,y,dir)
	end
end

function DoNudger(x,y,cell)
	cell.updated = true
	if cell.id == 114 then
		NudgeCell(x,y,cell.rot)
	elseif cell.id == 160 then
		NudgeCell(x,y,cell.rot)
	elseif cell.id == 161 then
		if not NudgeCell(x,y,cell.rot) then
			SetCell(x,y,{id=149,rot=cell.rot,lastvars=cell.lastvars,vars={},updated=true,eatencells={cell}})
		end
	elseif cell.id == 175 and cell.vars[1] then
		if not NudgeCell(x,y,cell.rot) then
			local cx,cy,cx2,cy2 = x,y,x,y
			if cell.rot == 1 then cx = x + 1 elseif cell.rot == 3 then cx = x - 1
			elseif cell.rot == 2 then cy = y + 1 elseif cell.rot == 0 then cy = y - 1 end
			if cell.rot == 3 then cx2 = x + 1 elseif cell.rot == 1 then cx2 = x - 1
			elseif cell.rot == 0 then cy2 = y + 1 elseif cell.rot == 2 then cy2 = y - 1 end
			if cell.vars[2] == (cell.rot+1)%4 then
				if PushCell(cx2,cy2,(cell.rot+1)%4,{force=1,replacecell={
				id=cell.vars[1],rot=cell.vars[2],lastvars={x,y,cell.vars[2]},updated=true,vars = DefaultVars(cell.vars[1])}}) then
					cell.vars = {}
				elseif PushCell(cx,cy,(cell.rot-1)%4,{force=1,replacecell={
				id=cell.vars[1],rot=cell.vars[2],lastvars={x,y,cell.vars[2]},updated=true,vars = DefaultVars(cell.vars[1])}}) then
					cell.vars = {}
				end
			else
				if PushCell(cx,cy,(cell.rot-1)%4,{force=1,replacecell={
				id=cell.vars[1],rot=cell.vars[2],lastvars={x,y,cell.vars[2]},updated=true,vars = DefaultVars(cell.vars[1])}}) then
					cell.vars = {}
				elseif PushCell(cx2,cy2,(cell.rot+1)%4,{force=1,replacecell={
				id=cell.vars[1],rot=cell.vars[2],lastvars={x,y,cell.vars[2]},updated=true,vars = DefaultVars(cell.vars[1])}}) then
					cell.vars = {}
				end
			end
		end
	elseif cell.id == 178 or cell.id == 179 or cell.id == 180 or cell.id == 181 or cell.id == 182 or cell.id == 183 or cell.id == 184 or cell.id == 185 then
		local newcell = table.copy(cell)
		local cx,cy,cdir,cell = NextCell(x,y,cell.rot,newcell)
		if cx then
			local checkedcell = GetCell(cx,cy)
			local vars = {}
			vars.forcetype = "scissor"
			vars.lastcell = newcell
			vars.lastx,vars.lasty,vars.lastdir = x,y,dir
			updatekey = updatekey + 1
			if IsDestroyer(checkedcell,cdir,cx,cy,vars) and (x ~= cx or y ~= cy) then
				SetCell(x,y,getempty())
				vars.active = true
				HandleNudge(checkedcell,cdir,cx,cy,vars)
				return
			elseif not IsUnbreakable(checkedcell,cdir,cx,cy,vars) and not IsNonexistant(checkedcell,cdir,cx,cy,vars) and (x ~= cx or y ~= cy) then
				local oldcell = CopyCell(cx,cy)
				SetCell(x,y,getempty())
				SetCell(cx,cy,newcell)
				if cell.id ~= 178 and cell.id ~= 180 then
					if cdir == 0 then cx = cx - 1 elseif cdir == 2 then cx = cx + 1
					elseif cdir == 1 then cy = cy - 1 elseif cdir == 3 then cy = cy + 1 end
					PushCell(cx,cy,cdir,{force=1,replacecell=table.copy(oldcell)})
					if cdir == 0 then cx = cx + 1 elseif cdir == 2 then cx = cx - 1
					elseif cdir == 1 then cy = cy + 1 elseif cdir == 3 then cy = cy - 1 end
				end
				if cell.id ~= 183 and cell.id ~= 185 then
					cdir = (cdir - 1)%4
					if cell.id == 178 or cell.id == 179 or cell.id == 182 then oldcell.rot = (oldcell.rot + 1)%4 end
					if cdir == 0 then cx = cx + 1 elseif cdir == 2 then cx = cx - 1
					elseif cdir == 1 then cy = cy + 1 elseif cdir == 3 then cy = cy - 1 end
					PushCell(cx,cy,cdir,{force=1,replacecell=table.copy(oldcell)})
					if cdir == 0 then cx = cx - 1 elseif cdir == 2 then cx = cx + 1
					elseif cdir == 1 then cy = cy - 1 elseif cdir == 3 then cy = cy + 1 end
					if cell.id == 178 or cell.id == 179 or cell.id == 182 then oldcell.rot = (oldcell.rot - 1)%4 end
					cdir = (cdir + 1)%4
				end
				if cell.id ~= 182 and cell.id ~= 184 then
					cdir = (cdir + 1)%4
					if cell.id == 178 or cell.id == 179 or cell.id == 183 then oldcell.rot = (oldcell.rot - 1)%4 end
					if cdir == 0 then cx = cx + 1 elseif cdir == 2 then cx = cx - 1
					elseif cdir == 1 then cy = cy + 1 elseif cdir == 3 then cy = cy - 1 end
					PushCell(cx,cy,cdir,{force=1,replacecell=table.copy(oldcell)})
					if cdir == 0 then cx = cx - 1 elseif cdir == 2 then cx = cx + 1
					elseif cdir == 1 then cy = cy - 1 elseif cdir == 3 then cy = cy + 1 end
				end
				return
			elseif IsNonexistant(checkedcell,cdir,cx,cy,vars) or x == cx and y == cy then
				SetCell(x,y,getempty())
				SetCell(cx,cy,newcell)
				vars.active = "replace"
				HandleNudge(checkedcell,cdir,cx,cy,vars)
				return
			end
			HandleNudge(checkedcell,cdir,cx,cy,vars)
		end
	elseif cell.id == 206 then
		local cx,cy = x,y
		if cell.rot == 0 then cx = x + 1 elseif cell.rot == 2 then cx = x - 1
		elseif cell.rot == 1 then cy = y + 1 elseif cell.rot == 3 then cy = y - 1 end
		local cell2 = GetCell(cx,cy)
		if cell2.id == 47 or cell2.id == 161 or ConvertId(cell2.id) == 123 and cell2.id ~= 211 then
			if math.random() <= .1 then
				cell2 = table.copy(cell)
				cell2.rot = (cell.rot+math.random(-1,1))%4
				SetCell(cx,cy,cell2)
				cell2.vars[math.random(3)] = math.random(5)-1
			else
				cell.vars[math.random(3)] = math.random(5)-1
				SetCell(cx,cy,getempty())
				cell.eatencells = {checkedcell}
			end
		else
			cx,cy = x,y
			if cell.rot == 1 then cx = x + 1 elseif cell.rot == 3 then cx = x - 1
			elseif cell.rot == 2 then cy = y + 1 elseif cell.rot == 0 then cy = y - 1 end
			local cell2 = GetCell(cx,cy)
			if cell2.id == 47 or cell2.id == 161 or ConvertId(cell2.id) == 123 and cell2.id ~= 211 then
				cell.rot = (cell.rot - 1)%4
				if math.random() <= .1 then
					cell2 = table.copy(cell)
					cell2.rot = (cell.rot+math.random(-1,1))%4
					SetCell(cx,cy,cell2)
					cell2.vars[math.random(3)] = math.random(5)-1
				else
					cell.vars[math.random(3)] = math.random(5)-1
					SetCell(cx,cy,getempty())
					cell.eatencells = {checkedcell}
				end
			else
				cx,cy = x,y
				if cell.rot == 3 then cx = x + 1 elseif cell.rot == 1 then cx = x - 1
				elseif cell.rot == 0 then cy = y + 1 elseif cell.rot == 2 then cy = y - 1 end
				local cell2 = GetCell(cx,cy)
				if cell2.id == 47 or cell2.id == 161 or ConvertId(cell2.id) == 123 and cell2.id ~= 211 then
					cell.rot = (cell.rot + 1)%4
					if math.random() <= .1 then
						cell2 = table.copy(cell)
						cell2.rot = (cell.rot+math.random(-1,1))%4
						SetCell(cx,cy,cell2)
						cell2.vars[math.random(3)] = math.random(5)-1
					else
						cell.vars[math.random(3)] = math.random(5)-1
						SetCell(cx,cy,getempty())
						cell.eatencells = {checkedcell}
					end
				end
			end
		end
		if not getAct(cell.vars[1],x,y,cell.rot) then 
			cell = GetCell(x,y)
			if cell.id ~= 206 then return end
			cell.rot = (cell.rot - 1)%4
			if not getAct(cell.vars[2],x,y,cell.rot) then
				cell = GetCell(x,y)
				if cell.id ~= 206 then return end
				cell.rot = (cell.rot + 2)%4
				if not getAct(cell.vars[3],x,y,cell.rot) then
					cell = GetCell(x,y)
					if cell.id ~= 206 then return end
					cell.rot = (cell.rot - 1)%4
					cell.id = (cell.vars[1] == 0 and 2 or cell.vars[1] == 1 and 72 or cell.vars[1] == 2 and 28 or cell.vars[1] == 3 and 59 or 269)
				end
			end
		end
	elseif cell.id == 242 then
		if not NudgeCell(x,y,cell.rot) then
			SetCell(x,y,{id=240,rot=cell.rot,lastvars=cell.lastvars,vars={},updated=true,eatencells={cell}})
		end
	elseif cell.id == 243 then
		if not NudgeCell(x,y,cell.rot) then
			SetCell(x,y,{id=241,rot=cell.rot,lastvars=cell.lastvars,vars={},updated=true,eatencells={cell}})
		end
	end
end

function DoCoinExtractor(x,y,cell)
	cell.updated = true
	local cx,cy = NextCell(x,y,(cell.rot+2)%4,nil,true)
	local ccx,ccy = NextCell(x,y,cell.rot)
	if cx then
		local gencell = GetCell(cx,cy)
		local tocell = GetCell(ccx,ccy)
		if IsNonexistant(tocell,cell.rot,ccx,ccy) and tocell.id ~= 223 and gencell.vars.coins then
			SetCell(ccx,ccy,{id=223,rot=0,lastvars={x,y,0},vars={}})
			gencell.vars.coins = gencell.vars.coins - 1
			if gencell.vars.coins == 0 then
				gencell.vars.coins = nil
			end
		elseif IsNonexistant(tocell,cell.rot,ccx,ccy) and tocell.id ~= 223 and gencell.id == 223 then
			SetCell(ccx,ccy,{id=223,rot=0,lastvars={x,y,0},vars={}})
			SetCell(cx,cy,getempty())
		end
	end
end

function DoGate(x,y,cell)
	if (cell.id == 32 and (cell.inl or cell.inr)) or (cell.id == 33 and (cell.inl and cell.inr)) or (cell.id == 34 and (cell.inl ~= cell.inr)) or
	   (cell.id == 35 and not (cell.inl or cell.inr)) or (cell.id == 36 and not (cell.inl and cell.inr)) or (cell.id == 37 and not (cell.inl ~= cell.inr)) or
	   (cell.id == 194 and (not cell.inl or cell.inr)) or (cell.id == 195 and (cell.inl or not cell.inr)) or (cell.id == 196 and (cell.inl and not cell.inr)) or (cell.id == 197 and (not cell.inl and cell.inr)) then
		cell.updated = true
		local cx,cy,cdir = NextCell(x,y,(cell.rot+2)%4,nil,true)
		if cx then
			local gencell = CopyCell(cx,cy)
			gencell = ToGenerate(gencell,cdir,cx,cy)
			if gencell then
				NextCell(cx,cy,(cdir+2)%4,gencell,nil,nil,true)	--converts gencell
				gencell.lastvars = table.copy(cell.lastvars)
				gencell.lastvars[3] = gencell.rot
				if cell.rot == 0 then x = x + 1 elseif cell.rot == 2 then x = x - 1
				elseif cell.rot == 1 then y = y + 1 elseif cell.rot == 3 then y = y - 1 end
				PushCell(x,y,cell.rot,{replacecell=gencell,noupdate=true,force=1})
			end
		end
	elseif (cell.id == 186 or cell.id == 187 or cell.id == 188 or cell.id == 189 or cell.id == 190 or cell.id == 191 or cell.id == 192 or cell.id == 193) then
		cell.updated = true
		if cell.output then
			if cell.rot == 0 then x = x + 1 elseif cell.rot == 2 then x = x - 1
			elseif cell.rot == 1 then y = y + 1 elseif cell.rot == 3 then y = y - 1 end
			PushCell(x,y,cell.rot,{replacecell=cell.output,noupdate=true,force=1})
		end
	end
end

function SendGlunkiSignal(x,y,life)
	local neighbors = GetNeighbors(x,y)
	for k,v in pairs(neighbors) do
		local cell2 = GetCell(v[1],v[2])
		if cell2.id == 212 and updatekey ~= cell2.updatekey and cell2.rot == k then
			cell2.updatekey = updatekey
			cell2.vars[4] = life
			SendGlunkiSignal(v[1],v[2],life+1)
		end
	end
end

function DoInfectious(x,y,cell)
	if cell.id == 123 then
		if cell.protected then SetCell(x,y,getempty()) GetCell(x,y).eatencells={cell} return end
		local neighbors = GetNeighbors(x,y)
		for k,v in pairs(neighbors) do
			local cell2 = GetCell(v[1],v[2])
			if not IsNonexistant(cell2,k,v[1],v[2]) and cell2.id ~= 123 and not IsUnbreakable(cell2,k,v[1],v[2],{forcetype="infect",lastcell=cell}) then
				SetCell(v[1],v[2],{id=123,rot=cell.rot,lastvars=cell.lastvars,vars={},updated=true,eatencells={cell2}})
				Play(infectsound)
			end
		end
	elseif cell.id == 124 then
		if cell.protected then SetCell(x,y,getempty()) GetCell(x,y).eatencells={cell} return end
		local neighbors = GetDiagonals(x,y)
		for k,v in pairs(neighbors) do
			local cell2 = GetCell(v[1],v[2])
			if not IsNonexistant(cell2,k,v[1],v[2]) and cell2.id ~= 124 and not IsUnbreakable(cell2,k,v[1],v[2],{forcetype="infect",lastcell=cell}) then
				SetCell(v[1],v[2],{id=124,rot=cell.rot,lastvars=cell.lastvars,vars={},updated=true,eatencells={cell2}})
				Play(infectsound)
			end
		end
	elseif cell.id == 125 then
		if cell.protected then SetCell(x,y,getempty()) GetCell(x,y).eatencells={cell} return end
		local neighbors = GetSurrounding(x,y)
		for k,v in pairs(neighbors) do
			local cell2 = GetCell(v[1],v[2])
			if not IsNonexistant(cell2,k,v[1],v[2]) and cell2.id ~= 125 and not IsUnbreakable(cell2,k,v[1],v[2],{forcetype="infect",lastcell=cell}) then
				SetCell(v[1],v[2],{id=125,rot=cell.rot,lastvars=cell.lastvars,vars={},updated=true,eatencells={cell2}})
				Play(infectsound)
			end
		end
	elseif cell.id == 127 then
		if cell.protected then SetCell(x,y,getempty()) GetCell(x,y).eatencells={cell} return end
		local neighbors = GetNeighbors(x,y)
		for k,v in pairs(neighbors) do
			local cell2 = GetCell(v[1],v[2])
			if cell2.id ~= 127 and not IsUnbreakable(cell2,k,v[1],v[2],{forcetype="infect",lastcell=cell}) then
				SetCell(v[1],v[2],{id=127,rot=cell.rot,lastvars=cell.lastvars,vars={},updated=true,eatencells={cell2}})
				Play(infectsound)
			end
		end
	elseif cell.id == 128 then
		if cell.protected then SetCell(x,y,getempty()) GetCell(x,y).eatencells={cell} return end
		local neighbors = GetNeighbors(x,y)
		for k,v in pairs(neighbors) do
			local cell2 = GetCell(v[1],v[2])
			if IsNonexistant(cell2,k,v[1],v[2]) then
				SetCell(v[1],v[2],{id=128,rot=cell.rot,lastvars=cell.lastvars,vars={},updated=true,eatencells={cell2}})
				Play(infectsound)
			end
		end
	elseif cell.id == 129 then
		if cell.protected then SetCell(x,y,getempty()) GetCell(x,y).eatencells={cell} return end
		local neighbors = GetDiagonals(x,y)
		for k,v in pairs(neighbors) do
			local cell2 = GetCell(v[1],v[2])
			if cell2.id ~= 129 and not IsUnbreakable(cell2,k,v[1],v[2],{forcetype="infect",lastcell=cell}) then
				SetCell(v[1],v[2],{id=129,rot=cell.rot,lastvars=cell.lastvars,vars={},updated=true,eatencells={cell2}})
				Play(infectsound)
			end
		end
	elseif cell.id == 130 then
		if cell.protected then SetCell(x,y,getempty()) GetCell(x,y).eatencells={cell} return end
		local neighbors = GetDiagonals(x,y)
		for k,v in pairs(neighbors) do
			local cell2 = GetCell(v[1],v[2])
			if IsNonexistant(cell2,k,v[1],v[2]) then
				SetCell(v[1],v[2],{id=130,rot=cell.rot,lastvars=cell.lastvars,vars={},updated=true,eatencells={cell2}})
				Play(infectsound)
			end
		end
	elseif cell.id == 131 then
		if cell.protected then SetCell(x,y,getempty()) GetCell(x,y).eatencells={cell} return end
		local neighbors = GetSurrounding(x,y)
		for k,v in pairs(neighbors) do
			local cell2 = GetCell(v[1],v[2])
			if cell2.id ~= 131 and not IsUnbreakable(cell2,k,v[1],v[2],{forcetype="infect",lastcell=cell}) then
				SetCell(v[1],v[2],{id=131,rot=cell.rot,lastvars=cell.lastvars,vars={},updated=true,eatencells={cell2}})
				Play(infectsound)
			end
		end
	elseif cell.id == 132 then
		if cell.protected then SetCell(x,y,getempty()) GetCell(x,y).eatencells={cell} return end
		local neighbors = GetSurrounding(x,y)
		for k,v in pairs(neighbors) do
			local cell2 = GetCell(v[1],v[2])
			if IsNonexistant(cell2,k,v[1],v[2]) then
				SetCell(v[1],v[2],{id=132,rot=cell.rot,lastvars=cell.lastvars,vars={},updated=true,eatencells={cell2}})
				Play(infectsound)
			end
		end
	elseif cell.id == 133 and math.random() < .5 then
		if cell.protected then SetCell(x,y,getempty()) GetCell(x,y).eatencells={cell} return end
		local neighbors = GetNeighbors(x,y)
		for k,v in pairs(neighbors) do
			local cell2 = GetCell(v[1],v[2])
			if IsNonexistant(cell2,k,v[1],v[2]) then
				SetCell(v[1],v[2],{id=133,rot=cell.rot,lastvars=cell.lastvars,vars={},updated=true,eatencells={cell2}})
				Play(infectsound)
			end
		end
	elseif cell.id == 134 and math.random() < .5 then
		if cell.protected then SetCell(x,y,getempty()) GetCell(x,y).eatencells={cell} return end
		local neighbors = GetNeighbors(x,y)
		for k,v in pairs(neighbors) do
			local cell2 = GetCell(v[1],v[2])
			if not IsNonexistant(cell2,k,v[1],v[2]) and cell2.id ~= 134 and not IsUnbreakable(cell2,k,v[1],v[2],{forcetype="infect",lastcell=cell}) then
				SetCell(v[1],v[2],{id=134,rot=cell.rot,lastvars=cell.lastvars,vars={},updated=true,eatencells={cell2}})
				Play(infectsound)
			end
		end
	elseif cell.id == 135 and math.random() < .5 then
		if cell.protected then SetCell(x,y,getempty()) GetCell(x,y).eatencells={cell} return end
		local neighbors = GetNeighbors(x,y)
		for k,v in pairs(neighbors) do
			local cell2 = GetCell(v[1],v[2])
			if cell2.id ~= 135 and not IsUnbreakable(cell2,k,v[1],v[2],{forcetype="infect",lastcell=cell}) then
				SetCell(v[1],v[2],{id=135,rot=cell.rot,lastvars=cell.lastvars,vars={},updated=true,eatencells={cell2}})
				Play(infectsound)
			end
		end
	elseif cell.id == 149 then
		if cell.protected then SetCell(x,y,getempty()) GetCell(x,y).eatencells={cell} return end
		local neighbors = GetSurrounding(x,y)
		local nnum = 0
		for k,v in pairs(neighbors) do
			local cell2 = GetCell(v[1],v[2])
			if cell2.id == 149 and not cell2.updated or IsNonexistant(cell2,k,v[1],v[2]) and cell2.updated then
				nnum = nnum+1
			elseif IsNonexistant(cell2,k,v[1],v[2]) then
				local neighbors = GetSurrounding(v[1],v[2])
				local nnum = 0
				for k,v in pairs(neighbors) do
					local cell2 = GetCell(v[1],v[2])
					if cell2.id == 149 and not cell2.updated or IsNonexistant(cell2,k,v[1],v[2]) and cell2.updated then
						nnum = nnum+1
					end
				end
				if nnum == 3 then
					SetCell(v[1],v[2],{id=149,rot=cell.rot,lastvars=cell.lastvars,vars={},updated=true,eatencells={cell2}})
				end
			elseif cell2.id ~= 149 or (v[1] == x or v[2] == y) and not IsUnbreakable(cell2,k,v[1],v[2],{forcetype="infect",lastcell=cell}) then
				SetCell(v[1],v[2],{id=149,rot=cell.rot,lastvars=cell.lastvars,vars={},updated=true,eatencells={cell2}})
				Play(infectsound)
			end
		end
		if nnum ~= 2 and nnum ~= 3 then
			SetCell(x,y,{id=0,rot=0,lastvars=cell.lastvars,vars={},updated=true,eatencells={cell}})
		end
	elseif cell.id == 211 or cell.id == 212 then
		if cell.protected then SetCell(x,y,cell.vars[1] and {
		id=cell.vars[1],rot=cell.vars[2],lastvars={x,y,cell.vars[2]},updated=true,vars = DefaultVars(cell.vars[1])}
		or getempty()) GetCell(x,y).eatencells={cell} return end
		if not cell.vars[1] then
			local neighbors = GetNeighbors(x,y)
			local todo = {[0]=true,true,true,true}
			while todo[0] or todo[1] or todo[2] or todo[3] do
				local k = math.random(0,3)
				local v = neighbors[k]
				local cell2 = GetCell(v[1],v[2])
				if not IsNonexistant(cell2,k,v[1],v[2]) and cell2.id ~= 211 and (cell2.id ~= 212 or cell.id == 211 and cell2.rot ~= k) and not IsUnbreakable(cell2,k,v[1],v[2],{forcetype="infect",lastcell=cell}) then
					local clone = {id=212,rot=k,updated=true,lastvars={x,y,k},vars={cell2.id,cell2.rot,250,cell.id == 212 and cell.vars[4] or 0},eatencells={cell2}}
					SetCell(v[1],v[2],clone)
					break
				end
				todo[k] = false
			end
			cell.vars[3] = cell.vars[3] - 1
			if cell.vars[3] == 0 then
				SetCell(x,y,getempty())
				GetCell(x,y).eatencells={cell}
				return
			end
			cell.testvar = cell.vars[3]
			if cell.id == 212 then
				cell.vars[4] = cell.vars[4] + 1
				if cell.vars[4] >= 250 then
					SetCell(x,y,getempty())
					GetCell(x,y).eatencells={cell}
				end
				cell.testvar = cell.vars[3].."\n"..cell.vars[4]
			end
		else
			if cell.id == 211 then
				if cell.vars[1] == 212 then
					cell.vars[1] = nil
					cell.vars[2] = nil
					cell.vars[4] = 25
					return
				end
				cell.vars[4] = math.max(cell.vars[4] - 1,0)
				cell.testvar = cell.vars[4]
				if cell.vars[4] == 0 then
					cell.vars[1] = nil
					cell.vars[2] = nil
					cell.vars[3] = 250
					cell.vars[4] = 25
					SendGlunkiSignal(x,y,0)
				end
				cell.testvar = cell.vars[3].."\n"..cell.vars[4]
			elseif cell.id == 212 then
				local cx,cy = x,y
				if cell.rot == 2 then cx = x + 1 elseif cell.rot == 0 then cx = x - 1
				elseif cell.rot == 3 then cy = y + 1 elseif cell.rot == 1 then cy = y - 1 end
				local cell2 = GetCell(cx,cy)
				if cell2.id == 211 or cell2.id == 212 then
					if not cell2.vars[1] then
						cell2.vars[1] = cell.vars[1]
						cell2.vars[2] = cell.vars[2]
						if cell2.id == 212 then cell2.vars[3] = 250 end
						cell2.updated = true
						cell.vars[1] = nil
						cell.vars[2] = nil
					end
				else
					local neighbors = GetNeighbors(x,y)
					for k,v in pairs(neighbors) do
						local cell2 = GetCell(v[1],v[2])
						if cell2.id == 211 or cell2.id == 212 then
							cell.rot = (k+2)%4
							break
						end
					end
					cell.vars[3] = cell.vars[3] - 1
					if cell.vars[3] == 0 then
						SetCell(x,y,cell.vars[1] and {
						id=cell.vars[1],rot=cell.vars[2],lastvars={x,y,cell.vars[2]},updated=true,vars = DefaultVars(cell.vars[1])}
						or getempty())
						GetCell(x,y).eatencells={cell}
					end
				end
				cell.vars[4] = cell.vars[4] + 1
				if cell.vars[4] >= 250 then
					SetCell(x,y,cell.vars[1] and {
					id=cell.vars[1],rot=cell.vars[2],lastvars={x,y,cell.vars[2]},updated=true,vars = DefaultVars(cell.vars[1])}
					or getempty())
					GetCell(x,y).eatencells={cell}
				end
				cell.testvar = cell.vars[3].."\n"..cell.vars[4]
			end
		end
	elseif cell.id == 234 then
		if cell.protected then SetCell(x,y,getempty()) GetCell(x,y).eatencells={cell} return end
		cell.updated = true
		local neighbors = GetNeighbors(x,y)
		for k,v in pairs(neighbors) do
			local cell2 = GetCell(v[1],v[2])
			if not IsNonexistant(cell2,k,v[1],v[2]) and cell2.id ~= 234 and not IsUnbreakable(cell2,k,v[1],v[2],{forcetype="burn",lastcell=cell}) and math.random() < .5 then
				SetCell(v[1],v[2],{id=234,rot=cell.rot,lastvars=cell.lastvars,vars={},updated=true,eatencells={cell2}})
				Play(infectsound)
			end
		end
		if math.random() < .5 then
			NudgeCell(x,y,(cell.rot-1)%4)
		elseif math.random() < .8 then
			NudgeCell(x,y,math.random(0,3))
		else
			SetCell(x,y,getempty())
			GetCell(x,y).eatencells={cell}
		end
	elseif cell.id == 240 or cell.id == 242 then
		if cell.protected then SetCell(x,y,getempty()) GetCell(x,y).eatencells={cell} return end
		cell.updated = true
		local neighbors = GetNeighbors(x,y)
		for k,v in pairs(neighbors) do
			local cell2 = GetCell(v[1],v[2])
			if not IsNonexistant(cell2,k,v[1],v[2]) and cell2.id ~= 240 and not IsUnbreakable(cell2,k,v[1],v[2],{forcetype="burn",lastcell=cell}) then
				SetCell(v[1],v[2],{id=240,rot=cell.rot,lastvars=cell.lastvars,vars={},updated=true,eatencells={cell2}})
				Play(infectsound)
			end
		end
		if cell.id == 240 then
			SetCell(x,y,getempty())
			GetCell(x,y).eatencells={cell}
		end
	elseif cell.id == 241 or cell.id == 243 then
		if cell.protected then SetCell(x,y,getempty()) GetCell(x,y).eatencells={cell} return end
		cell.updated = true
		local neighbors = GetSurrounding(x,y)
		for k,v in pairs(neighbors) do
			local cell2 = GetCell(v[1],v[2])
			if not IsNonexistant(cell2,k,v[1],v[2]) and cell2.id ~= 241 and not IsUnbreakable(cell2,k,v[1],v[2],{forcetype="burn",lastcell=cell}) then
				SetCell(v[1],v[2],{id=241,rot=cell.rot,lastvars=cell.lastvars,vars={},updated=true,eatencells={cell2}})
				Play(infectsound)
			end
		end
		if cell.id == 241 then
			SetCell(x,y,getempty())
			GetCell(x,y).eatencells={cell}
		end
	end
end

playerpos,freezecam = {},false
function DoPlayer(x,y,cell)
	cell.updated = true
	if held then
		if cell.id == 288 or cell.id == 293 or cell.id == 294 or cell.id == 295 or cell.id == 296 or cell.id == 298 then
			cell.protected = true
		end
		if cell.id == 289 or cell.id == 293 then
			PullCell(x,y,held,{force=1})
		elseif cell.id == 290 or cell.id == 294 then
			GraspCell(x,y,held,{force=1})
		elseif cell.id == 291 or cell.id == 295 then
			local cx,cy = x,y
			if held == 0 then cx = x + 1 elseif held == 2 then cx = x - 1
			elseif held == 1 then cy = y + 1 elseif held == 3 then cy = y - 1 end
			SwapCells(x,y,(held+2)%4,cx,cy,held)
		elseif cell.id == 297 or cell.id == 298 then
			SliceCell(x,y,held)
		elseif cell.id == 292 or cell.id == 296 then
			NudgeCell(x,y,held)
		else
			PushCell(x,y,held,{force=1})
		end
	end
	table.insert(playerpos,{x+.5,y+.5})
	cam.tarx,cam.tary = 0,0 
	freezecam = true
end

--behold the funcularity
subticks = {
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 199 and (c.rot == 0 and c.id ~= 202) and c.id ~= 203 and c.id ~= 204 end,function(x,y,c) DoCheater(x,y,c) end, "upleft", 199) end,
	function() return RunOn(function(c) return not c.updated and (ConvertId(c.id) == 199 and c.rot == 2 or c.id == 202 and c.rot == 0) and c.id ~= 203 and c.id ~= 204 end,function(x,y,c) DoCheater(x,y,c) end, "upright", 199) end,
	function() return RunOn(function(c) return not c.updated and (ConvertId(c.id) == 199 and c.rot == 3 and c.id ~= 202 or c.id == 203 or c.id == 204) end,function(x,y,c) DoCheater(x,y,c) end, "rightdown", 199) end,
	function() return RunOn(function(c) return not c.updated and (ConvertId(c.id) == 199 and c.rot == 1 or c.id == 202 and c.rot == 3) and c.id ~= 203 and c.id ~= 204 end,function(x,y,c) DoCheater(x,y,c) end, "rightup", 199) end,
	function() return RunOn(function(c) return c.id == 285 end,																			function(x,y,c) DoThawer(x,y,c) end, "rightup", 285) end,
	function() return RunOn(function(c) return ConvertId(c.id) == 25 end,																function(x,y,c) DoFreezer(x,y,c) end, "rightup", 25) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 43 end,												function(x,y,c) DoEffectGiver(x,y,c) end, "rightup", 43) end,
	function() return RunOn(function(c) return not c.updated and c.id == 266 end,														function(x,y,c) DoDegravitizer(x,y,c) end, "rightup", 266) end,
	function() return RunOn(function(c) return not c.updated and (ConvertId(c.id) == 146 and c.id ~= 148 and c.rot == 0 or c.id == 148 and not c.hupdated and (c.rot == 0 or c.rot == 1))end,function(x,y,c) DoTimewarper(x,y,c,0) end, "upleft", 146) end,
	function() return RunOn(function(c) return not c.updated and (ConvertId(c.id) == 146 and c.id ~= 148 and c.rot == 2 or c.id == 148 and not c.hupdated and (c.rot == 2 or c.rot == 3))end,function(x,y,c) DoTimewarper(x,y,c,2) end, "upright", 146) end,
	function() return RunOn(function(c) return not c.updated and (ConvertId(c.id) == 146 and c.rot == 3 or c.id == 148 and c.rot == 0)end,function(x,y,c) DoTimewarper(x,y,c,3) end, "rightdown", 146) end,
	function() return RunOn(function(c) return not c.updated and (ConvertId(c.id) == 146 and c.rot == 1 or c.id == 148 and c.rot == 2)end,function(x,y,c) DoTimewarper(x,y,c,1) end, "rightup", 146) end,
	function() return RunOn(function(c) return not c.updated and ((c.id == 237 or c.id == 267) and c.rot == 0 or (c.id == 238 or c.id == 268) and not c.hupdated and (c.rot == 0 or c.rot == 1))end,function(x,y,c) DoTransformer(x,y,c,0) end, "upleft", 237) end,
	function() return RunOn(function(c) return not c.updated and ((c.id == 237 or c.id == 267) and c.rot == 2 or (c.id == 238 or c.id == 268) and not c.hupdated and (c.rot == 2 or c.rot == 3))end,function(x,y,c) DoTransformer(x,y,c,2) end, "upright", 237) end,
	function() return RunOn(function(c) return not c.updated and (ConvertId(c.id) == 237 and c.rot == 3 or (c.id == 238 or c.id == 268) and c.rot == 0)end,function(x,y,c) DoTransformer(x,y,c,3) end, "rightdown", 237) end,
	function() return RunOn(function(c) return not c.updated and (ConvertId(c.id) == 237 and c.rot == 1 or (c.id == 238 or c.id == 268) and c.rot == 2)end,function(x,y,c) DoTransformer(x,y,c,1) end, "rightup", 237) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 15 end,												function(x,y,c) DoHMirror(x,y,c) end, "upright", 15) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 15 end,												function(x,y,c) DoVMirror(x,y,c) end, "rightup", 15) end,
	function() return RunOn(function(c) return not c.updated and c.id == 80 end,														function(x,y,c) DoDMirror(x,y,c) end, "rightup", 15) end,
	function() return RunOn(function(c) return not c.updated and (c.id == 44 and c.rot == 0 or c.id == 155 and not c.hupdated and (c.rot == 0 or c.rot == 1) or c.id == 250 and (c.rot == 0 or c.rot == 2) and not c.firstupdated or c.id == 251 and not c.Rupdated) end,function(x,y,c) DoIntaker(x,y,c,0) end, "upright", 44) end,
	function() return RunOn(function(c) return not c.updated and (c.id == 44 and c.rot == 2 or c.id == 155 and not c.hupdated and (c.rot == 2 or c.rot == 3) or c.id == 250 and (c.rot == 0 or c.rot == 2) or c.id == 251 and not c.Lupdated) end,function(x,y,c) DoIntaker(x,y,c,2) end, "upleft", 44) end,
	function() return RunOn(function(c) return not c.updated and (c.id == 44 and c.rot == 3 or c.id == 155 and (c.rot == 0 or c.rot == 3) or c.id == 250 and (c.rot == 1 or c.rot == 3) and not c.firstupdated or c.id == 251 and not c.Uupdated) end,function(x,y,c) DoIntaker(x,y,c,3) end, "rightup", 44) end,
	function() return RunOn(function(c) return not c.updated and (c.id == 44 and c.rot == 1 or c.id == 155 and (c.rot == 2 or c.rot == 1) or c.id == 250 and (c.rot == 1 or c.rot == 3) or c.id == 251) end,function(x,y,c) DoIntaker(x,y,c,1) end, "rightdown", 44) end,
	function() return RunOn(function(c) return not c.updated and (ConvertId(c.id) == 106 and c.id ~= 107 and c.rot == 0 or c.id == 107 and not c.hupdated and (c.rot == 0 or c.rot == 1))end,function(x,y,c) DoShifter(x,y,c,0) end, "upleft", 106) end,
	function() return RunOn(function(c) return not c.updated and (ConvertId(c.id) == 106 and c.id ~= 107 and c.rot == 2 or c.id == 107 and not c.hupdated and (c.rot == 2 or c.rot == 3))end,function(x,y,c) DoShifter(x,y,c,2) end, "upright", 106) end,
	function() return RunOn(function(c) return not c.updated and (ConvertId(c.id) == 106 and c.rot == 3 or c.id == 107 and c.rot == 0)end,function(x,y,c) DoShifter(x,y,c,3) end, "rightdown", 106) end,
	function() return RunOn(function(c) return not c.updated and (ConvertId(c.id) == 106 and c.rot == 1 or c.id == 107 and c.rot == 2)end,function(x,y,c) DoShifter(x,y,c,1) end, "rightup", 106) end,
	function() return RunOn(function(c) return not c.updated and c.id == 235 end,														function(x,y,c) DoCreator(x,y,c) end, "upleft", 235) end,
	function() return RunOn(function(c) return not c.updated and c.id == 166 and c.rot == 0 end,										function(x,y,c) DoMemory(x,y,c) end, "upleft", 166) end,
	function() return RunOn(function(c) return not c.updated and c.id == 166 and c.rot == 2 end,										function(x,y,c) DoMemory(x,y,c) end, "upright", 166) end,
	function() return RunOn(function(c) return not c.updated and c.id == 166 and c.rot == 3 end,										function(x,y,c) DoMemory(x,y,c) end, "rightdown", 166) end,
	function() return RunOn(function(c) return not c.updated and c.id == 166 and c.rot == 1 end,										function(x,y,c) DoMemory(x,y,c) end, "rightup", 166) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 55 and c.rot == 0 end,								function(x,y,c) DoSuperGenerator(x,y,c) end, "upleft", 55) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 55 and c.rot == 2 end,								function(x,y,c) DoSuperGenerator(x,y,c) end, "upright", 55) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 55 and c.rot == 3 end,								function(x,y,c) DoSuperGenerator(x,y,c) end, "rightdown", 55) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 55 and c.rot == 1 end,								function(x,y,c) DoSuperGenerator(x,y,c) end, "rightup", 55) end,
	function() return RunOn(function(c) return not c.updated and (ConvertId(c.id) == 3 and c.id ~= 23 and c.rot == 0 or c.id == 23 and not c.hupdated and (c.rot == 0 or c.rot == 1)) end,function(x,y,c) DoGenerator(x,y,c,0) end, "upleft", 3) end,
	function() return RunOn(function(c) return not c.updated and (ConvertId(c.id) == 3 and c.id ~= 23 and c.rot == 2 or c.id == 23 and not c.hupdated and (c.rot == 2 or c.rot == 3)) end,function(x,y,c) DoGenerator(x,y,c,2) end, "upright", 3) end,
	function() return RunOn(function(c) return not c.updated and (ConvertId(c.id) == 3 and c.rot == 3 or c.id == 23 and c.rot == 0) end,function(x,y,c) DoGenerator(x,y,c,3) end, "rightdown", 3) end,
	function() return RunOn(function(c) return not c.updated and (ConvertId(c.id) == 3 and c.rot == 1 or c.id == 23 and c.rot == 2) end,function(x,y,c) DoGenerator(x,y,c,1) end, "rightup", 3) end,
	function() return RunOn(function(c) return not c.updated and c.id == 177 and c.rot == 0 end,										function(x,y,c) DoSuperReplicator(x,y,c) end, "upleft", 177) end,
	function() return RunOn(function(c) return not c.updated and c.id == 177 and c.rot == 2 end,										function(x,y,c) DoSuperReplicator(x,y,c) end, "upright", 177) end,
	function() return RunOn(function(c) return not c.updated and c.id == 177 and c.rot == 3 end,										function(x,y,c) DoSuperReplicator(x,y,c) end, "rightdown", 177) end,
	function() return RunOn(function(c) return not c.updated and c.id == 177 and c.rot == 1 end,										function(x,y,c) DoSuperReplicator(x,y,c) end, "rightup", 177) end,
	function() return RunOn(function(c) return not c.updated and (ConvertId(c.id) == 45 and c.id ~= 46 and c.rot == 0 or c.id == 46 and not c.hupdated and (c.rot == 0 or c.rot == 1)) end,function(x,y,c) DoReplicator(x,y,c,0) end, "upleft", 45) end,
	function() return RunOn(function(c) return not c.updated and (ConvertId(c.id) == 45 and c.id ~= 46 and c.rot == 2 or c.id == 46 and not c.hupdated and (c.rot == 2 or c.rot == 3)) end,function(x,y,c) DoReplicator(x,y,c,2) end, "upright", 45) end,
	function() return RunOn(function(c) return not c.updated and (ConvertId(c.id) == 45 and c.rot == 3 or c.id == 46 and c.rot == 0) end,function(x,y,c) DoReplicator(x,y,c,3) end, "rightdown", 45) end,
	function() return RunOn(function(c) return not c.updated and (ConvertId(c.id) == 45 and c.rot == 1 or c.id == 46 and c.rot == 2) end,function(x,y,c) DoReplicator(x,y,c,1) end, "rightup", 45) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 30 end,												function(x,y,c) DoFlipper(x,y,c) end, "upright", 30) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 9 end,												function(x,y,c) DoRotator(x,y,c) end, "rightup", 9) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 18 end,												function(x,y,c) DoGear(x,y,c) end, "rightup", 18) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 19 end,												function(x,y,c) DoGear(x,y,c) end, "leftup", 19) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 17 end,												function(x,y,c) DoRedirector(x,y,c) end, "rightup", 17) end,
	function() return RunOn(function(c) return not c.updated and c.id == 236 and c.vars[1] == 1 end,									function(x,y,c) DoInertia(x,y,c,0) end, "upleft", 236) end,
	function() return RunOn(function(c) return not c.updated and c.id == 236 and c.vars[1] == -1 end,									function(x,y,c) DoInertia(x,y,c,2) end, "upright", 236) end,
	function() return RunOn(function(c) return not c.updated and c.id == 236 and c.vars[2] == -1 end,									function(x,y,c) DoInertia(x,y,c,3) end, "rightdown", 236) end,
	function() return RunOn(function(c) return not c.updated and c.id == 236 and c.vars[2] == 1 end,									function(x,y,c) DoInertia(x,y,c,1) end, "rightup", 236) end,
	function() return RunOn(function(c) return not c.updated and c.id == 248 end,														function(x,y,c) DoSuperImpulsor(x,y,0) end, "upleft", 248) end,
	function() return RunOn(function(c) return not c.updated and c.id == 248 end,														function(x,y,c) DoSuperImpulsor(x,y,2) end, "upright", 248) end,
	function() return RunOn(function(c) return not c.updated and c.id == 248 end,														function(x,y,c) DoSuperImpulsor(x,y,3) end, "rightdown", 248) end,
	function() return RunOn(function(c) return not c.updated and c.id == 248 end,														function(x,y,c) DoSuperImpulsor(x,y,1) end, "rightup", 248) end,
	function() return RunOn(function(c) return not c.updated and c.id == 29 end,														function(x,y,c) DoImpulsor(x,y,0) end, "upleft", 29) end,
	function() return RunOn(function(c) return not c.updated and c.id == 29 end,														function(x,y,c) DoImpulsor(x,y,2) end, "upright", 29) end,
	function() return RunOn(function(c) return not c.updated and c.id == 29 end,														function(x,y,c) DoImpulsor(x,y,3) end, "rightdown", 29) end,
	function() return RunOn(function(c) return not c.updated and c.id == 29 end,														function(x,y,c) DoImpulsor(x,y,1) end, "rightup", 29) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 81 and (c.id ~= 227 or c.rot == 0) and (c.id ~= 228 or c.rot == 0 or c.rot == 1) end,function(x,y,c) DoGrapulsor(x,y,c,0) end, "upleft", 81) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 81 and (c.id ~= 227 or c.rot == 2) and (c.id ~= 228 or c.rot == 2 or c.rot == 3) end,function(x,y,c) DoGrapulsor(x,y,c,2) end, "upright", 81) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 81 and (c.id ~= 227 or c.rot == 3) and (c.id ~= 228 or c.rot == 3 or c.rot == 0) end,function(x,y,c) DoGrapulsor(x,y,c,3) end, "rightdown", 81) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 81 and (c.id ~= 227 or c.rot == 1) and (c.id ~= 228 or c.rot == 1 or c.rot == 2) end,function(x,y,c) DoGrapulsor(x,y,c,1) end, "rightup", 81) end,
	function() return RunOn(function(c) return not c.updated and c.id == 50 end,														function(x,y,c) DoSuperRepulsor(x,y,0) end, "upleft", 50) end,
	function() return RunOn(function(c) return not c.updated and c.id == 50 end,														function(x,y,c) DoSuperRepulsor(x,y,2) end, "upright", 50) end,
	function() return RunOn(function(c) return not c.updated and c.id == 50 end,														function(x,y,c) DoSuperRepulsor(x,y,3) end, "rightdown", 50) end,
	function() return RunOn(function(c) return not c.updated and c.id == 50 end,														function(x,y,c) DoSuperRepulsor(x,y,1) end, "rightup", 50) end,
	function() return RunOn(function(c) return c.vars.timerepulseright end,																function(x,y,c) c.vars.timerepulseright = nil; PushCell(x,y,0,{force=1,noupdate=true}) end, "upleft", "timerep") end,
	function() return RunOn(function(c) return c.vars.timerepulseleft end,																function(x,y,c) c.vars.timerepulseleft = nil; PushCell(x,y,2,{force=1,noupdate=true}) end, "upright", "timerep") end,
	function() return RunOn(function(c) return c.vars.timerepulseup end,																function(x,y,c) c.vars.timerepulseup = nil; PushCell(x,y,3,{force=1,noupdate=true}) end, "rightdown", "timerep") end,
	function() return RunOn(function(c) return c.vars.timerepulsedown end,																function(x,y,c) c.vars.timerepulsedown = nil; PushCell(x,y,1,{force=1,noupdate=true}) end, "rightup", "timerep") end,
	function() return RunOn(function(c) return not c.updated and c.id == 222 end,														function(x,y,c) DoTimeRepulsor(x,y,c) end, "upright", 222) end,
	function() return RunOn(function(c) return not c.updated and c.id == 21 end,														function(x,y,c) DoRepulsor(x,y,0) end, "upleft", 21) end,
	function() return RunOn(function(c) return not c.updated and c.id == 21 end,														function(x,y,c) DoRepulsor(x,y,2) end, "upright", 21) end,
	function() return RunOn(function(c) return not c.updated and c.id == 21 end,														function(x,y,c) DoRepulsor(x,y,3) end, "rightdown", 21) end,
	function() return RunOn(function(c) return not c.updated and c.id == 21 end,														function(x,y,c) DoRepulsor(x,y,1) end, "rightup", 21) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 156 end,											function(x,y,c) DoMagnet(x,y,c) end, "rightup", 156) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 306 end,											function(x,y,c) DoTermite(x,y,c) end, "rightup", 306) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 306 end,											function(x,y,c) DoTermite(x,y,c) end, "leftup", 306) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 58 and c.rot == 0 end,								function(x,y,c) DoDriller(x,y,c) end, "upleft", 58) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 58 and c.rot == 2 end,								function(x,y,c) DoDriller(x,y,c) end, "upright", 58) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 58 and c.rot == 3 end,								function(x,y,c) DoDriller(x,y,c) end, "rightdown", 58) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 58 and c.rot == 1 end,								function(x,y,c) DoDriller(x,y,c) end, "rightup", 58) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 14 and c.rot == 0 end,								function(x,y,c) DoPuller(x,y,c) end, "upleft", 14) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 14 and c.rot == 2 end,								function(x,y,c) DoPuller(x,y,c) end, "upright", 14) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 14 and c.rot == 3 end,								function(x,y,c) DoPuller(x,y,c) end, "rightdown", 14) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 14 and c.rot == 1 end,								function(x,y,c) DoPuller(x,y,c) end, "rightup", 14) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 71 and c.rot == 0 end,								function(x,y,c) DoGrasper(x,y,c) end, "upleft", 71) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 71 and c.rot == 2 end,								function(x,y,c) DoGrasper(x,y,c) end, "upright", 71) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 71 and c.rot == 3 end,								function(x,y,c) DoGrasper(x,y,c) end, "rightdown", 71) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 71 and c.rot == 1 end,								function(x,y,c) DoGrasper(x,y,c) end, "rightup", 71) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 284 and c.rot == 0 end,								function(x,y,c) DoSuperPusher(x,y,c) end, "upright", 284) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 284 and c.rot == 2 end,								function(x,y,c) DoSuperPusher(x,y,c) end, "upleft", 284) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 284 and c.rot == 3 end,								function(x,y,c) DoSuperPusher(x,y,c) end, "rightup", 284) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 284 and c.rot == 1 end,								function(x,y,c) DoSuperPusher(x,y,c) end, "rightdown", 284) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 2 and c.rot == 0 end,								function(x,y,c) DoPusher(x,y,c) end, "upright", 2) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 2 and c.rot == 2 end,								function(x,y,c) DoPusher(x,y,c) end, "upleft", 2) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 2 and c.rot == 3 end,								function(x,y,c) DoPusher(x,y,c) end, "rightup", 2) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 2 and c.rot == 1 end,								function(x,y,c) DoPusher(x,y,c) end, "rightdown", 2) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 115 and c.rot == 0 end,								function(x,y,c) DoSlicer(x,y,c) end, "upleft", 115) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 115 and c.rot == 2 end,								function(x,y,c) DoSlicer(x,y,c) end, "upright", 115) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 115 and c.rot == 3 end,								function(x,y,c) DoSlicer(x,y,c) end, "rightdown", 115) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 115 and c.rot == 1 end,								function(x,y,c) DoSlicer(x,y,c) end, "rightup", 115) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 114 and c.rot == 0 end,								function(x,y,c) DoNudger(x,y,c) end, "upleft", 114) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 114 and c.rot == 2 end,								function(x,y,c) DoNudger(x,y,c) end, "upright", 114) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 114 and c.rot == 3 end,								function(x,y,c) DoNudger(x,y,c) end, "rightdown", 114) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 114 and c.rot == 1 end,								function(x,y,c) DoNudger(x,y,c) end, "rightup", 114) end,
	function() return RunOn(function(c) return c.vars.gravdir == 0 and c.id ~= 232 and not c.gupdated end,								function(x,y,c) c.gupdated = true; PushCell(x,y,0,{force=1}) end, "upleft", "gravity") end,
	function() return RunOn(function(c) return c.vars.gravdir == 2 and c.id ~= 232 and not c.gupdated end,								function(x,y,c) c.gupdated = true; PushCell(x,y,2,{force=1}) end, "upright", "gravity") end,
	function() return RunOn(function(c) return c.vars.gravdir == 3 and c.id ~= 232 and not c.gupdated end,								function(x,y,c) c.gupdated = true; PushCell(x,y,3,{force=1}) end, "rightdown", "gravity") end,
	function() return RunOn(function(c) return c.vars.gravdir == 1 and c.id ~= 232 and not c.gupdated end,								function(x,y,c) c.gupdated = true; PushCell(x,y,1,{force=1}) end, "rightup", "gravity") end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 32 and c.rot == 0 end,								function(x,y,c) DoGate(x,y,c) end, "upright", 32) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 32 and c.rot == 2 end,								function(x,y,c) DoGate(x,y,c) end, "upleft", 32) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 32 and c.rot == 3 end,								function(x,y,c) DoGate(x,y,c) end, "rightup", 32) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 32 and c.rot == 1 end,								function(x,y,c) DoGate(x,y,c) end, "rightdown", 32) end,
	function() return RunOn(function(c) return not c.updated and c.id == 230 and c.rot == 0 end,			 							function(x,y,c) DoCoinExtractor(x,y,c) end, "upright", 230) end,
	function() return RunOn(function(c) return not c.updated and c.id == 230 and c.rot == 2 end,										function(x,y,c) DoCoinExtractor(x,y,c) end, "upleft", 230) end,
	function() return RunOn(function(c) return not c.updated and c.id == 230 and c.rot == 3 end,										function(x,y,c) DoCoinExtractor(x,y,c) end, "rightup", 230) end,
	function() return RunOn(function(c) return not c.updated and c.id == 230 and c.rot == 1 end,										function(x,y,c) DoCoinExtractor(x,y,c) end, "rightdown", 230) end,
	function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == 123 or c.id == 242 or c.id == 243 end,				function(x,y,c) DoInfectious(x,y,c) end, "rightup", 123) end,
	function() freezecam = false; playerpos = {}; local success = RunOn(function(c) return not c.updated and ConvertId(c.id) == 239 end,function(x,y,c) DoPlayer(x,y,c) end, held == 0 and "upleft" or held == 2 and "upright" or held == 3 and "rightdown" or "rightup", 239); for i=1,#playerpos do cam.tarx = cam.tarx+cam.tarzoom*playerpos[i][1]/#playerpos cam.tary = cam.tary+cam.tarzoom*playerpos[i][2]/#playerpos end return success end,
	CheckEnemies,
}

function ResetCells(first)
	chunks.all.new = chunks.all.new or {}
	RunOn(function() return true end,
	function(x,y,c)
		if first then
			c.lastvars = {x,y,c.rot}
			c.eatencells = nil
			c.testvar = nil
		end
		if subtick == 0 then
			local ids = AllChunkIds(c)
			chunks[math.floor(y*.04)][math.floor(x*.04)].new = chunks[math.floor(y*.04)][math.floor(x*.04)].new or {}
			for i=1,#ids do
				chunks[math.floor(y*.04)][math.floor(x*.04)].new[ids[i]] = true
				chunks.all.new[ids[i]] = true
			end
			for k,v in pairs(c) do
				if k ~= "id" and k ~= "rot" and k ~= "vars" and k ~= "lastvars" and k ~= "eatencells" then
					c[k] = nil
				end
			end
		end
	end
	,"rightup","all")
	if subtick == 0 then
		for y=0,height*.04-.04 do
			for x=0,width*.04-.04 do
				chunks[y][x] = chunks[y][x].new or chunks[y][x]
			end
		end
		chunks.all = chunks.all.new
	end
end

function DoTick(first)
	if mainmenu then return end
	if updatekey > 1000000000000 then updatekey = 0 end --juuuust in case
	if supdatekey > 1000000000000 then supdatekey = 0 end
	if stickkey > 1000000000000 then stickkey = 0 end
	if not held then
		if love.keyboard.isDown("d") or love.keyboard.isDown("right") then held = 0
		elseif love.keyboard.isDown("a") or love.keyboard.isDown("left") then held = 2
		elseif love.keyboard.isDown("w") or love.keyboard.isDown("up") then held = 3
		elseif love.keyboard.isDown("s") or love.keyboard.isDown("down") then held = 1 end
	end
	Trigger('tick', first)
	if subticking then
		ResetCells(first)
		repeat
			subtick = subtick%#subticks+1
		until subticks[subtick]() or subtick == #subticks
		if subtick == #subticks then subtick = 0 Trigger('tick-cycle', first) end
	else
		ResetCells(first)
		for i=subtick%#subticks+1,#subticks do
			subticks[i]()
		end
		subtick = 0
		Trigger('tick-cycle', first)
	end
	held = nil
	isinitial = false
	dtime = 0
	itime = 0
end

function love.load()
	--lol empty
end

mx,my = 0,0
function love.update(dt)
	delta = dt
	winxm = love.graphics.getWidth()/800
	winym = love.graphics.getHeight()/600
	centerx = 400*winxm
	centery = 300*winym
	hoveredbutton = nil
	for i=1,#buttonorder do
		local b = buttons[buttonorder[i]]
		if b.isenabled() then
			local x,y,x2,y2
			if b.halign == -1 then
				x = b.x*uiscale
				x2 = x+b.w*uiscale
			elseif b.halign == 1 then
				x2 = love.graphics.getWidth()-b.x*uiscale
				x = x2-b.w*uiscale
			else
				x = b.x*uiscale+centerx-b.w*.5*uiscale
				x2 = x+b.w*uiscale
			end
			if b.valign == -1 then
				y = b.y*uiscale
				y2 = y+b.h*uiscale
			elseif b.valign == 1 then
				y2 = love.graphics.getHeight()-b.y*uiscale
				y = y2-b.h*uiscale
			else
				y = b.y*uiscale+centery-b.h*.5*uiscale
				y2 = y+b.h*uiscale
			end
			if love.mouse.getX() >= x and love.mouse.getX() <= x2 and love.mouse.getY() >= y and love.mouse.getY() <= y2 then
				hoveredbutton = b
				if love.mouse.isDown(1) or love.mouse.isDown(2) or love.mouse.isDown(3) then placecells = false end
			end
		end
	end
	if (love.mouse.isDown(1) or love.mouse.isDown(2) or love.mouse.isDown(3)) and hoveredbutton and hoveredbutton.ishold then
		hoveredbutton.onclick(hoveredbutton)
	end
	if love.mouse.isDown(1) and not hoveredbutton and not puzzle and placecells then
		local x = math.floor((love.mouse.getX()+cam.x-400*winxm)/cam.zoom)
		local y = math.floor((love.mouse.getY()+cam.y-300*winym)/cam.zoom)
		for cy=y-math.ceil(chosen.size*.5)+(chosen.shape == "Square" and 1 or 0),y+math.floor(chosen.size*.5) do
			for cx=x-math.ceil(chosen.size*.5)+(chosen.shape == "Square" and 1 or 0),x+math.floor(chosen.size*.5) do
				if (chosen.shape == "Square" or math.distSqr(cx-x,cy-y) <= chosen.size*chosen.size/4) and (chosen.mode ~= "Or" or GetCell(cx,cy).id == 0) and (chosen.mode ~= "And" or GetCell(cx,cy).id ~= 0) then
					if chosen.randrot then hudrot = chosen.rot chosen.rot = math.random(0,3) end
					if IsBackground(chosen.id) then
						SetPlaceable(cx,cy,chosen.id)
					else
						if not undocells.topush and width*height < 40000 then
							undocells.topush = table.copy(cells)
							undocells.topush.isinitial = isinitial
						end
						PlaceCell(cx,cy,{id=chosen.id,rot=chosen.rot,lastvars={cx,cy,chosen.rot}})
					end
				end
			end
		end	
	elseif love.mouse.isDown(1) and not hoveredbutton and not puzzle and selection.on then
		local x = math.floor((love.mouse.getX()+cam.x-400*winxm)/cam.zoom)
		local y = math.floor((love.mouse.getY()+cam.y-300*winym)/cam.zoom)
		if selection.x > x then selection.x = x end
		if selection.y > y then selection.y = y end
		selection.w = x-selection.x + 1
		selection.h = y-selection.y + 1
	elseif love.mouse.isDown(2) and not hoveredbutton and not puzzle and placecells then
		local x = math.floor((love.mouse.getX()+cam.x-400*winxm)/cam.zoom)
		local y = math.floor((love.mouse.getY()+cam.y-300*winym)/cam.zoom)
		for cy=y-math.ceil(chosen.size*.5)+(chosen.shape == "Square" and 1 or 0),y+math.floor(chosen.size*.5) do
			for cx=x-math.ceil(chosen.size*.5)+(chosen.shape == "Square" and 1 or 0),x+math.floor(chosen.size*.5) do
				if (chosen.shape == "Square" or math.distSqr(cx-x,cy-y) <= chosen.size*chosen.size/4) then
					if erasebg then
						SetPlaceable(cx,cy)
					else
						if not undocells.topush and width*height < 40000 then
							undocells.topush = table.copy(cells)
							undocells.topush.isinitial = isinitial
						end
						PlaceCell(cx,cy,getempty())
					end
				end
			end
		end	
	end
	if love.mouse.isDown(3) and not inmenu and not mainmenu and not winscreen then
		local x,y = love.mouse.getX(),love.mouse.getY()
		cam.x = cam.x + mx - x
		cam.y = cam.y + my - y
		cam.tarx = cam.tarx + mx - x
		cam.tary = cam.tary + my - y
		mx,my = x,y
	else
		mx,my = love.mouse.getX(),love.mouse.getY()
	end
	if not paused and not inmenu and not mainmenu then
		dtime = dtime + dt
		if dtime > delay then
			for i=1,tpu do
				DoTick(i==1)
			end
		end
	end
	freezecam = freezecam and not paused
	if not freezecam and love.keyboard.isDown("lctrl") or love.keyboard.isDown("lgui") then
		if love.keyboard.isDown("w") or love.keyboard.isDown("up") then cam.tary = cam.tary - math.min(dt*1200,100) end
		if love.keyboard.isDown("s") or love.keyboard.isDown("down") then cam.tary = cam.tary + math.min(dt*1200,100) end
		if love.keyboard.isDown("a") or love.keyboard.isDown("left") then cam.tarx = cam.tarx - math.min(dt*1200,100) end
		if love.keyboard.isDown("d") or love.keyboard.isDown("right") then cam.tarx = cam.tarx + math.min(dt*1200,100) end
	elseif not freezecam then
		if love.keyboard.isDown("w") or love.keyboard.isDown("up") then cam.tary = cam.tary - math.min(dt*600,50) end
		if love.keyboard.isDown("s") or love.keyboard.isDown("down") then cam.tary = cam.tary + math.min(dt*600,50) end
		if love.keyboard.isDown("a") or love.keyboard.isDown("left") then cam.tarx = cam.tarx - math.min(dt*600,50) end
		if love.keyboard.isDown("d") or love.keyboard.isDown("right") then cam.tarx = cam.tarx + math.min(dt*600,50) end
	end
	cam.tarx = math.max(math.min(cam.tarx,width*cam.tarzoom-100+400*winxm),100-400*winxm)
	cam.tary = math.max(math.min(cam.tary,height*cam.tarzoom-100+300*winym),100-300*winym)
	for i=0,dt*6 do
		cam.x = math.lerp(cam.x,cam.tarx,.1)
		cam.y = math.lerp(cam.y,cam.tary,.1)
		cam.zoom = math.lerp(cam.zoom,cam.tarzoom,.1)
	end
	cam.x = math.abs(cam.x-cam.tarx) < .01 and cam.tarx or cam.x
	cam.y = math.abs(cam.y-cam.tary) < .01 and cam.tary or cam.y
	cam.zoom = math.abs(cam.zoom-cam.tarzoom) < .01 and cam.tarzoom or cam.zoom
	itime = math.min(itime + dt,delay)
	hudlerp = math.min(hudlerp + dt*10,1)
	for i=1,#particles do
		particles[i]:update(dt)
	end
	menuparticles:emit(dt*1000)
	menuparticles:update(dt)
	if typing then
		love.keyboard.setTextInput(true)
	else
		love.keyboard.setTextInput(false)
	end
end

function DrawCell(cell,x,y,ip)
	local cx,cy,crot
	local lerp = itime/delay
	if ip then
		cx,cy,crot = math.floor(math.graphiclerp(cell.lastvars[1],x,lerp)*cam.zoom-cam.x+cam.zoom*.5+400*winxm),math.floor(math.graphiclerp(cell.lastvars[2],y,lerp)*cam.zoom-cam.y+cam.zoom*.5+300*winym),math.graphiclerp(cell.lastvars[3],cell.lastvars[3]+((cell.rot-cell.lastvars[3]+2)%4-2),lerp)*math.pi*.5
	else
		cx,cy,crot = math.floor(x*cam.zoom-cam.x+cam.zoom*.5+400*winxm),math.floor(y*cam.zoom-cam.y+cam.zoom*.5+300*winym),cell.rot*math.pi*.5
	end
	local fancy = fancy
	if x == math.floor((love.mouse.getX()+cam.x-400*winxm)/cam.zoom) and y == math.floor((love.mouse.getY()+cam.y-300*winym)/cam.zoom) then
		fancy = true
	end
	local ctex = cell.id == 206 and tex["lluea"..cell.vars[1]] or tex[cell.id] or tex.X
	local ctexsize = cell.id == 206 and texsize["lluea"..cell.vars[1]] or texsize[cell.id] or texsize.X
	if cell.id ~= 0 then 
		love.graphics.draw(ctex,cx,cy,crot,cam.zoom/ctexsize.w,cam.zoom/ctexsize.h,ctexsize.w2,ctexsize.h2)
		if type(ModStuff.onCellDraw[cell.id]) == "function" then
			ModStuff.onCellDraw[cell.id](cell, x, y, ip)
		end
		Trigger('cellrender', cell, x, y, ip)
	end
	if fancy and ip then
		for i=1,#(cell.eatencells or {}) do
			local ecell = cell.eatencells[i]
			if ecell.id ~= 0 then 
				local ctex = tex[ecell.id] or tex.X
				local ctexsize = texsize[ecell.id] or texsize.X
				love.graphics.draw(ctex,math.lerp(ecell.lastvars[1]*cam.zoom-cam.x+cam.zoom*.5+400*winxm,cell.id == 0 and x*cam.zoom-cam.x+cam.zoom*.5+400*winxm or cx,lerp),math.lerp(ecell.lastvars[2]*cam.zoom-cam.y+cam.zoom*.5+300*winym,cell.id == 0 and y*cam.zoom-cam.y+cam.zoom*.5+300*winym or cy,lerp),ecell.lastvars[3]*math.pi*.5,math.lerp(cam.zoom/ctexsize.w,0,lerp),math.lerp(cam.zoom/ctexsize.w,0,lerp),ctexsize.w2,ctexsize.h2)
			end
		end
	end
	if (cell.id == 165 or cell.id == 175 or cell.id == 198 or cell.id == 211 or cell.id == 212 or cell.id == 235) and cell.vars[1] then
		love.graphics.draw((tex[cell.vars[1]] or tex.X),cx,cy,cell.vars[2]*math.pi*.5,cam.zoom/(texsize[cell.vars[1]] or texsize.X).w*.5,cam.zoom/(texsize[cell.vars[1]] or texsize.X).h*.5,(texsize[cell.vars[1]] or texsize.X).w2,(texsize[cell.vars[1]] or texsize.X).h2)
	elseif cell.id == 166 and cell.vars[1] then
		love.graphics.draw((tex[cell.vars[1]] or tex.X),cx,cy,cell.vars[2]*math.pi*.5,cam.zoom/(texsize[cell.vars[1]] or texsize.X).w*.2,cam.zoom/(texsize[cell.vars[1]] or texsize.X).h*.2,(texsize[cell.vars[1]] or texsize.X).w2,(texsize[cell.vars[1]] or texsize.X).h2)
	elseif cell.id == 233 and cell.vars[1] then
		love.graphics.draw((tex[cell.vars[1]] or tex.X),cx,cy,0,cam.zoom/(texsize[cell.vars[1]] or texsize.X).w*.2,cam.zoom/(texsize[cell.vars[1]] or texsize.X).h*.2,(texsize[cell.vars[1]] or texsize.X).w2,(texsize[cell.vars[1]] or texsize.X).h2)
	elseif cell.id == 206 then
		local ctex = tex["lluea"..cell.vars[2].."l"]
		local ctexsize =  texsize["lluea"..cell.vars[2].."l"]
		love.graphics.draw(ctex,cx,cy,crot,cam.zoom/ctexsize.w,cam.zoom/ctexsize.h,ctexsize.w2,ctexsize.h2)
		local ctex = tex["lluea"..cell.vars[3].."r"]
		local ctexsize =  texsize["lluea"..cell.vars[3].."r"]
		love.graphics.draw(ctex,cx,cy,crot,cam.zoom/ctexsize.w,cam.zoom/ctexsize.h,ctexsize.w2,ctexsize.h2)
	elseif cell.id == 221 and fancy then
		local r,g,b,a = love.graphics.getColor()
		love.graphics.setColor(0,0,0,1)
		love.graphics.printf(cell.vars[1].."\n"..cell.vars[2],cx-.225*cam.zoom,cy-.225*cam.zoom,20,"center",0,cam.zoom/40,cam.zoom/40)
		love.graphics.setColor(r,g,b,a)
		love.graphics.printf(cell.vars[1].."\n"..cell.vars[2],cx-.25*cam.zoom,cy-.25*cam.zoom,20,"center",0,cam.zoom/40,cam.zoom/40)
	elseif (cell.id == 224 or cell.id == 299) and fancy then
		local r,g,b,a = love.graphics.getColor()
		love.graphics.setColor(0,0,0,1)
		love.graphics.printf(cell.vars[1],cx-.075*cam.zoom,cy+.225*cam.zoom,20,"right",0,cam.zoom/40,cam.zoom/40)
		love.graphics.setColor(r,g,b,a)
		love.graphics.printf(cell.vars[1],cx-.1*cam.zoom,cy+.2*cam.zoom,20,"right",0,cam.zoom/40,cam.zoom/40)
	end
	if fancy then
		if cell.frozen then love.graphics.draw((tex.frozen),cx,cy,0,cam.zoom/texsize.frozen.w,cam.zoom/texsize.frozen.h,texsize.frozen.w2,texsize.frozen.h2) end
		if cell.protected then love.graphics.draw((tex.protected),cx,cy,0,cam.zoom/texsize.protected.w,cam.zoom/texsize.protected.h,texsize.protected.w2,texsize.protected.h2) end
		if cell.locked then love.graphics.draw((tex.locked),cx,cy,0,cam.zoom/texsize.locked.w,cam.zoom/texsize.locked.h,texsize.locked.w2,texsize.locked.h2) end
		if cell.clamped then love.graphics.draw((tex.clamped),cx,cy,0,cam.zoom/texsize.clamped.w,cam.zoom/texsize.clamped.h,texsize.clamped.w2,texsize.clamped.h2) end
		if cell.latched then love.graphics.draw((tex.latched),cx,cy,0,cam.zoom/texsize.latched.w,cam.zoom/texsize.latched.h,texsize.latched.w2,texsize.latched.h2) end
		if cell.sealed then love.graphics.draw((tex.sealed),cx,cy,0,cam.zoom/texsize.sealed.w,cam.zoom/texsize.sealed.h,texsize.sealed.w2,texsize.sealed.h2) end
		if cell.bolted then love.graphics.draw((tex.bolted),cx,cy,0,cam.zoom/texsize.bolted.w,cam.zoom/texsize.bolted.h,texsize.bolted.w2,texsize.bolted.h2) end
		if cell.reinforced then love.graphics.draw((tex.reinforced),cx,cy,0,cam.zoom/texsize.reinforced.w,cam.zoom/texsize.reinforced.h,texsize.reinforced.w2,texsize.reinforced.h2) end
		if cell.sticky then love.graphics.draw((tex.sticky),cx,cy,0,cam.zoom/texsize.sticky.w,cam.zoom/texsize.sticky.h,texsize.sticky.w2,texsize.sticky.h2) end
		if cell.thawed then love.graphics.draw((tex.thawed),cx,cy,0,cam.zoom/texsize.thawed.w,cam.zoom/texsize.thawed.h,texsize.thawed.w2,texsize.thawed.h2) end
		if cell.vars.gravdir then love.graphics.draw((tex["grav"..cell.vars.gravdir]),cx,cy,0,cam.zoom/texsize["grav"..cell.vars.gravdir].w,cam.zoom/texsize["grav"..cell.vars.gravdir].h,texsize["grav"..cell.vars.gravdir].w2,texsize["grav"..cell.vars.gravdir].h2) end
		if cell.vars.coins then
			love.graphics.draw((tex.coins),cx,cy,0,cam.zoom/texsize.coins.w,cam.zoom/texsize.coins.h,texsize.coins.w2,texsize.coins.h2)
			local r,g,b,a = love.graphics.getColor()
			love.graphics.setColor(0,0,0,1)
			love.graphics.print(cell.vars.coins,cx-.175*cam.zoom,cy-.1125*cam.zoom,0,cam.zoom/40,cam.zoom/40)
			love.graphics.setColor(r,g,b,a)
			love.graphics.print(cell.vars.coins,cx-.2*cam.zoom,cy-.1375*cam.zoom,0,cam.zoom/40,cam.zoom/40)
		end
		if cell.id ~= 0 and cell.rot ~= 0 and cell.rot ~= 1 and cell.rot ~= 2 and cell.rot ~= 3 then love.graphics.draw((tex.invalidrot),cx,cy,0,cam.zoom/texsize.invalidrot.w,cam.zoom/texsize.invalidrot.h,texsize.invalidrot.w2,texsize.invalidrot.h2) end
	end
	if cell.id ~= 0 and ip then
		if GetPlaceable(x,y) and tex[GetPlaceable(x,y).."overlay"] then
			local t,ts = tex[GetPlaceable(x,y).."overlay"] or tex.X,texsize[GetPlaceable(x,y).."overlay"]
			love.graphics.draw(t,cx,cy,crot,cam.zoom/ts.w,cam.zoom/ts.h,ts.w2,ts.h2)
		end
	end
	if dodebug and cell.testvar then
		love.graphics.print(tostring(cell.testvar),cx,cy)
	end
end

function love.draw()
	if not mainmenu then
		local cellcanv = love.graphics.newCanvas(love.graphics.getWidth(),love.graphics.getHeight())
		love.graphics.setColor(1,1,1,1)
		love.graphics.draw(bgsprites,math.floor(cam.zoom-cam.x+cam.zoom*.5+400*winxm)+.49,math.floor(cam.zoom-cam.y+cam.zoom*.5+300*winym)+.49,0,cam.zoom/texsize[0].w,cam.zoom/texsize[0].h,texsize[0].w2,texsize[0].h2)
		for y=math.max(math.floor((cam.y-300*winym)/cam.zoom),0),math.min(math.floor((cam.y+300*winym)/cam.zoom)+1,height-1) do
			for x=math.max(math.floor((cam.x-400*winxm)/cam.zoom),0),math.min(math.floor((cam.x+400*winxm)/cam.zoom)+1,width-1) do
				local cx,cy = math.floor(x*cam.zoom-cam.x+cam.zoom*.5+400*winxm),math.floor(y*cam.zoom-cam.y+cam.zoom*.5+300*winym)
				local p = GetPlaceable(x,y)
				if p then
					love.graphics.draw(tex[p],cx,cy,0,cam.zoom/texsize[p].w,cam.zoom/texsize[p].h,texsize[p].w2,texsize[p].h2)
				end
			end
		end
		love.graphics.setCanvas(cellcanv)
		for y=math.max(math.floor((cam.y-300*winym)/cam.zoom),0),math.min(math.floor((cam.y+300*winym)/cam.zoom)+1,height-1) do
			for x=math.max(math.floor((cam.x-400*winxm)/cam.zoom),0),math.min(math.floor((cam.x+400*winxm)/cam.zoom)+1,width-1) do
				local cx,cy = math.floor(x*cam.zoom-cam.x+cam.zoom*.5+400*winxm),math.floor(y*cam.zoom-cam.y+cam.zoom*.5+300*winym)
				DrawCell(cells[y][x],x,y,true)
			end
		end
		love.graphics.setCanvas()
		if fancy then
			love.graphics.setColor(0,0,0,.25)
			love.graphics.draw(cellcanv,.15*cam.zoom,.15*cam.zoom)
			love.graphics.setColor(1,1,1,1)
		end
		love.graphics.draw(cellcanv,.49,.49)
		cellcanv:release()
		Trigger('grid-render')
		if fancy then
			for i=1,#particles do
				love.graphics.draw(particles[i],math.floor(cam.zoom-cam.x+cam.zoom*.5)+400*winxm,math.floor(cam.zoom-cam.y+cam.zoom*.5)+300*winym,0,cam.zoom/texsize[0].w,cam.zoom/texsize[0].h,texsize[0].w2,texsize[0].h2)
			end
		end
		if draggedcell then
			local mx = (love.mouse.getX()+cam.x-400*winxm)/cam.zoom-.5
			local my = (love.mouse.getY()+cam.y-300*winym)/cam.zoom-.5
			DrawCell(draggedcell,mx,my,false)
		elseif pasting then
			love.graphics.setColor(1,1,1,.5)
			local mx = math.floor((love.mouse.getX()+cam.x-400*winxm)/cam.zoom)
			local my = math.floor((love.mouse.getY()+cam.y-300*winym)/cam.zoom)
			for y=0,#copied do
				for x=0,#copied[0] do
					DrawCell(copied[y][x],x+mx,y+my,false)
				end
			end
			love.graphics.setColor(1,1,1,.25)
			love.graphics.rectangle("fill",(mx-.5)*cam.zoom-cam.x+cam.zoom*.5+400*winxm,(my-.5)*cam.zoom-cam.y+cam.zoom*.5+300*winym,#copied[0]*cam.zoom+cam.zoom,#copied*cam.zoom+cam.zoom)
		elseif selection.on then
			love.graphics.setColor(1,1,1,.25)
			local cx,cy = math.floor((selection.x-.5)*cam.zoom-cam.x+cam.zoom*.5+400*winxm),math.floor((selection.y-.5)*cam.zoom-cam.y+cam.zoom*.5+300*winym)
			love.graphics.rectangle("fill",cx,cy,selection.w*cam.zoom,selection.h*cam.zoom)
		elseif not hoveredbutton and not puzzle then
			love.graphics.setColor(1,1,1,.25)
			local mx = math.floor((love.mouse.getX()+cam.x-400*winxm)/cam.zoom)
			local my = math.floor((love.mouse.getY()+cam.y-300*winym)/cam.zoom)
			for y=my-math.ceil(chosen.size*.5)+(chosen.shape == "Square" and 1 or 0),my+math.floor(chosen.size*.5) do
				for x=mx-math.ceil(chosen.size*.5)+(chosen.shape == "Square" and 1 or 0),mx+math.floor(chosen.size*.5) do
					if (chosen.shape == "Square" or math.distSqr(x-mx,y-my) <= chosen.size*chosen.size/4) and (chosen.mode ~= "Or" or GetCell(x,y).id == 0) and (chosen.mode ~= "And" or GetCell(x,y).id ~= 0) then
						love.graphics.draw(tex[chosen.id] or tex.X,math.floor(x*cam.zoom-cam.x+cam.zoom*.5+400*winxm),math.floor(y*cam.zoom-cam.y+cam.zoom*.5+300*winym),chosen.rot*math.pi*.5,cam.zoom/(texsize[chosen.id] or texsize.X).w,cam.zoom/(texsize[chosen.id] or texsize.X).h,(texsize[chosen.id] or texsize.X).w2,(texsize[chosen.id] or texsize.X).h2)
					end
				end
			end
		end
		if dodebug then
			love.graphics.setColor(1,0,0,1)
			for y=0,#chunks do
				for x=0,#chunks[0] do
					love.graphics.line(math.floor((x-.02)*25*cam.zoom-cam.x+cam.zoom*.5+400*winxm)+.5,math.floor((y-.02)*25*cam.zoom-cam.y+cam.zoom*.5+300*winym)+.5,math.floor((x+.98)*25*cam.zoom-cam.x+cam.zoom*.5+400*winxm)+.5,math.floor((y-.02)*25*cam.zoom-cam.y+cam.zoom*.5+300*winym)+.5)
					love.graphics.line(math.floor((x-.02)*25*cam.zoom-cam.x+cam.zoom*.5+400*winxm)+.5,math.floor((y-.02)*25*cam.zoom-cam.y+cam.zoom*.5+300*winym)+.5,math.floor((x-.02)*25*cam.zoom-cam.x+cam.zoom*.5+400*winxm)+.5,math.floor((y+.98)*25*cam.zoom-cam.y+cam.zoom*.5+300*winym)+.5)
				
				end
			end
		end
		love.graphics.setColor(1,1,1,1)
		love.graphics.printf(title,centerx,10*uiscale,1000,"center",0,2*uiscale,2*uiscale,500)
		love.graphics.printf(subtitle,centerx,30*uiscale,300,"center",0,uiscale,uiscale,150)
	elseif mainmenu == 1 then
		love.graphics.setColor(1,1,1,1)
		love.graphics.draw(menuparticles,centerx,centery)
		love.graphics.draw(tex.logo,centerx,centery-100*uiscale,math.sin(love.timer.getTime())/10,uiscale,uiscale,texsize.logo.w2,texsize.logo.h2)
		love.graphics.setColor(0,0,0,1)
		local t = "Version 2.-1.5 PRE-RELEASE STUPID NOT FUL\nCreated by KyYay\nOriginal Cell Machine by Sam Hogan"
		love.graphics.printf(t,centerx+uiscale,centery-math.sin(love.timer.getTime()/2)*10*uiscale-24*uiscale,400,"center",0,uiscale,uiscale,200)
		love.graphics.setColor(1,1,1,1)
		love.graphics.printf(t,centerx,centery-math.sin(love.timer.getTime()/2)*10*uiscale-25*uiscale,400,"center",0,uiscale,uiscale,200)
	else
		love.graphics.setColor(1,1,1,1)
		love.graphics.draw(menuparticles,centerx,centery)
	end

	local stallbtn
	local jx,jy = 0,0
	for i=1,#buttonorder do
		local b = buttons[buttonorder[i]]
		if b.isenabled() then
			if b == hoveredbutton then
				if love.mouse.isDown(1) then
					love.graphics.setColor(b.clickcolor)
				else
					love.graphics.setColor(b.hovercolor)
				end
			else	
				love.graphics.setColor(b.color)
			end
			local x,y
			if b.halign == -1 then
				x = b.x*uiscale+texsize[b.icon].w2*b.w*uiscale/texsize[b.icon].w
			elseif b.halign == 1 then
				x = love.graphics.getWidth()-b.x*uiscale-texsize[b.icon].w2*b.w*uiscale/texsize[b.icon].w
			else
				x = b.x*uiscale+centerx
			end
			if b.valign == -1 then
				y = b.y*uiscale+texsize[b.icon].h2*b.h*uiscale/texsize[b.icon].h
			elseif b.valign == 1 then
				y = love.graphics.getHeight()-b.y*uiscale-texsize[b.icon].h2*b.h*uiscale/texsize[b.icon].h
			else
				y = b.y*uiscale+centery
			end
			x,y = math.round(x),math.round(y)
			love.graphics.draw(tex[b.icon],x,y,type(b.rot) == "function" and b.rot() or b.rot or 0,b.w/texsize[b.icon].w*uiscale,b.h/texsize[b.icon].h*uiscale,texsize[b.icon].w2,texsize[b.icon].h2)
			if hoveredbutton == b and b.name then
				stallbtn = b
			end
			if buttonorder[i] == "propertybg" then
				for i=1,#propertynames do
					love.graphics.setColor(1,1,1,1)
					love.graphics.printf(propertynames[i]..": "..chosen.data[i],x,y-(#propertynames-i+1)*25*uiscale+b.h*uiscale*.5+5*uiscale,100,"center",0,uiscale,uiscale,50,0)
				end
			elseif buttonorder[i] == "joystick" and hoveredbutton == b and love.mouse.isDown(1) then
				jx,jy = -love.mouse.getX()+love.graphics.getWidth()-90*uiscale,-love.mouse.getY()+love.graphics.getHeight()-120*uiscale
				if jx*jx+jy*jy > 50*50*uiscale*uiscale then
					jx,jy = 0,0
				end
			elseif string.sub(buttonorder[i],1,8) == "topuzzle" then
				love.graphics.setColor(0,0,0,1)
				love.graphics.printf(string.sub(buttonorder[i],9,99),x+2*uiscale,y+2*uiscale,100,"center",0,2*uiscale,2*uiscale,50,5)
				love.graphics.setColor(1,1,1,1)
				love.graphics.printf(string.sub(buttonorder[i],9,99),x,y,100,"center",0,2*uiscale,2*uiscale,50,5)
			end
		end
	end
	love.graphics.setColor(1,1,1,1)
	if mobile and not mainmenu then
		love.graphics.draw(tex.joystick,love.graphics.getWidth()-jx-90*uiscale,love.graphics.getHeight()-jy-120*uiscale,0,uiscale,uiscale,texsize.joystick.w2,texsize.joystick.h2)
	end
	if inmenu and not winscreen and not mainmenu then
		local skew = math.sin(love.timer.getTime()*1.3)/8
		love.graphics.setColor(rainbow(.25))
		local scale = math.lerp(2,2.1,math.sin(love.timer.getTime())+1)*uiscale
		love.graphics.printf("CelLua Machine",centerx,centery-127*uiscale,100,"center",0,scale,2*uiscale,50,8,skew)
		love.graphics.setColor(rainbow(.5))
		local scale = math.lerp(2,2.075,math.sin(love.timer.getTime()-.2)+1)*uiscale
		love.graphics.printf("CelLua Machine",centerx,centery-127*uiscale,100,"center",0,scale,2*uiscale,50,8,skew)
		love.graphics.setColor(rainbow(.75))
		local scale = math.lerp(2,2.05,math.sin(love.timer.getTime()-.4)+1)*uiscale
		love.graphics.printf("CelLua Machine",centerx,centery-127*uiscale,100,"center",0,scale,2*uiscale,50,8,skew)
		love.graphics.setColor(1,1,1,.5)
		local scale = math.lerp(2,2.025,math.sin(love.timer.getTime()-.6)+1)*uiscale
		love.graphics.printf("CelLua Machine",centerx,centery-127*uiscale,100,"center",0,scale,2*uiscale,50,8,skew)
		love.graphics.setColor(1,1,1,.75)
		local scale = math.lerp(2,2.01,math.sin(love.timer.getTime()-.6)+1)*uiscale
		love.graphics.printf("CelLua Machine",centerx,centery-127*uiscale,100,"center",0,scale,2*uiscale,50,8,skew)
		love.graphics.setColor(1,1,1,1)
		love.graphics.printf("CelLua Machine",centerx,centery-127*uiscale,100,"center",0,2*uiscale,2*uiscale,50,8,skew)
		love.graphics.setColor(0.5,0.5,0.5,1)
		love.graphics.rectangle("fill",math.lerp(centerx-152*uiscale,centerx+148*uiscale,delay),centery-109.5*uiscale,4*uiscale,10*uiscale)
		love.graphics.rectangle("fill",math.lerp(centerx-152*uiscale,centerx+148*uiscale,(tpu-1)/9),centery-87.5*uiscale,4*uiscale,10*uiscale)
		love.graphics.rectangle("fill",math.lerp(centerx-152*uiscale,centerx+148*uiscale,volume),centery-65.5*uiscale,4*uiscale,10*uiscale)
		love.graphics.rectangle("fill",math.lerp(centerx-152*uiscale,centerx+148*uiscale,svolume),centery-43.5*uiscale,4*uiscale,10*uiscale)
		if not puzzle then love.graphics.rectangle("fill",math.lerp(centerx-152*uiscale,centerx+148*uiscale,(border-1)/(#bordercells-1)),centery-21.5*uiscale,4*uiscale,10*uiscale) end
		love.graphics.rectangle("fill",math.lerp(centerx-152*uiscale,centerx+148*uiscale,(newuiscale-.5)*.66666),centery+.5,4*uiscale,10*uiscale)
		love.graphics.setColor(1,1,1,1)
		love.graphics.print("Update delay: "..math.round(delay*100)/100 .."s",centerx-150*uiscale,300*winym-120*uiscale,0,uiscale,uiscale)
		love.graphics.print("Ticks per update: "..tpu,centerx-150*uiscale,300*winym-99*uiscale,0,uiscale,uiscale)
		love.graphics.print("Music Volume: "..volume*100 .."%",centerx-150*uiscale,300*winym-76*uiscale,0,uiscale,uiscale)
		love.graphics.print("SFX Volume: "..svolume*100 .."%",centerx-150*uiscale,300*winym-55*uiscale,0,uiscale,uiscale)
		if not puzzle then
			love.graphics.print("Border: "..border.." ("..cellinfo[bordercells[border]].name..")",centerx-150*uiscale,centery-32*uiscale,0,uiscale,uiscale)
			love.graphics.print("Width",centerx-100*uiscale,centery+38*uiscale,0,uiscale,uiscale)
			love.graphics.print("Height",centerx+50*uiscale,centery+38*uiscale,0,uiscale,uiscale)
			if typing == 1 then love.graphics.print(newwidth.."_",centerx-95*uiscale,centery+52*uiscale,0,2*uiscale,2*uiscale) else love.graphics.print(newwidth,centerx-95*uiscale,centery+52*uiscale,0,2*uiscale,2*uiscale) end
			if typing == 2 then love.graphics.print(newheight.."_",centerx+55*uiscale,centery+52*uiscale,0,2*uiscale,2*uiscale) else love.graphics.print(newheight,centerx+55*uiscale,centery+52*uiscale,0,2*uiscale,2*uiscale) end
		end
		love.graphics.print("UI Scale: "..newuiscale*100 .."%",centerx-150*uiscale,300*winym-10*uiscale,0,uiscale,uiscale)
	elseif winscreen then
		local skew = math.sin(love.timer.getTime()*1.3)/8
		love.graphics.setColor(rainbow(.25))
		local scale = math.lerp(4,4.2,math.sin(love.timer.getTime())+1)
		love.graphics.printf("Victory!",centerx,centery-75,100,"center",0,scale,4,50,8,skew)
		love.graphics.setColor(rainbow(.5))
		local scale = math.lerp(4,4.15,math.sin(love.timer.getTime()-.2)+1)
		love.graphics.printf("Victory!",centerx,centery-75,100,"center",0,scale,4,50,8,skew)
		love.graphics.setColor(rainbow(.75))
		local scale = math.lerp(4,4.1,math.sin(love.timer.getTime()-.4)+1)
		love.graphics.printf("Victory!",centerx,centery-75,100,"center",0,scale,4,50,8,skew)
		love.graphics.setColor(1,1,1,.5)
		local scale = math.lerp(4,4.05,math.sin(love.timer.getTime()-.6)+1)
		love.graphics.printf("Victory!",centerx,centery-75,100,"center",0,scale,4,50,8,skew)
		love.graphics.setColor(1,1,1,.75)
		local scale = math.lerp(4,4.02,math.sin(love.timer.getTime()-.6)+1)
		love.graphics.printf("Victory!",centerx,centery-75,100,"center",0,scale,4,50,8,skew)
		love.graphics.setColor(1,1,1,1)
		love.graphics.printf("Victory!",centerx,centery-75,100,"center",0,4,4,50,8,skew)
	elseif mainmenu == 3 then
		love.graphics.setColor(0.5,0.5,0.5,1)
		love.graphics.rectangle("fill",math.lerp(centerx-152*uiscale,centerx+148*uiscale,volume),centery-65.5*uiscale,4*uiscale,10*uiscale)
		love.graphics.rectangle("fill",math.lerp(centerx-152*uiscale,centerx+148*uiscale,svolume),centery-43.5*uiscale,4*uiscale,10*uiscale)
		love.graphics.rectangle("fill",math.lerp(centerx-152*uiscale,centerx+148*uiscale,(newuiscale-.5)*.66666),centery+.5,4*uiscale,10*uiscale)
		love.graphics.setColor(1,1,1,1)
		love.graphics.print("Music Volume: "..volume*100 .."%",centerx-150*uiscale,300*winym-76*uiscale,0,uiscale,uiscale)
		love.graphics.print("SFX Volume: "..svolume*100 .."%",centerx-150*uiscale,300*winym-55*uiscale,0,uiscale,uiscale)
		love.graphics.print("UI Scale: "..newuiscale*100 .."%",centerx-150*uiscale,300*winym-10*uiscale,0,uiscale,uiscale)
	end
	if stallbtn and showinfo then
		local high = stallbtn.desc and 100*uiscale or 40*uiscale
		local x = math.max(math.min(love.mouse.getX(),love.graphics.getWidth()-300*uiscale),0)
		local y = math.max(math.min(love.mouse.getY(),love.graphics.getHeight()-high),0)
		love.graphics.setColor(0.5,0.5,0.5,1)
		love.graphics.rectangle("fill",x,y,300*uiscale,high)
		love.graphics.setColor(0.25,0.25,0.25,1)
		love.graphics.rectangle("fill",x+2*uiscale,y+2*uiscale,296*uiscale,high-4*uiscale)
		love.graphics.setColor(1,1,1,1)
		love.graphics.printf(stallbtn.name,x+10*uiscale,y+10*uiscale,9001,nil,nil,2*uiscale,2*uiscale)
		if stallbtn.desc then love.graphics.printf(stallbtn.desc,x+10*uiscale,y+30*uiscale,280,nil,nil,uiscale,uiscale) end
	end
	love.graphics.setColor(1,1,1,0.5)
	love.graphics.print("FPS: ".. 1/delta,2,2) 
	if subticking then
		love.graphics.print("Subtick: "..subtick.."/"..#subticks,2,12) 
	end

	Trigger('render')
end

function love.keypressed(key)
	if typing then
		if typing == 1 then
			if tonumber(key) then
				newwidth = tonumber(string.sub(tostring(newwidth)..key,1,3))
			elseif key == "backspace" then
				newwidth = tonumber(string.sub(tostring(newwidth),1,string.len(tostring(newwidth))-1)) or 0
			end
		elseif typing == 2 then
			if tonumber(key) then
				newheight = tonumber(string.sub(tostring(newheight)..key,1,3))
			elseif key == "backspace" then
				newheight = tonumber(string.sub(tostring(newheight),1,string.len(tostring(newheight))-1)) or 0
			end
		end
	else
		if key == "q" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("lgui")) then
			FlipH()
		elseif key == "e" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("lgui")) then
			FlipV()
		elseif key == "q" then
			RotateCCW()
		elseif key == "e" then
			RotateCW()
		elseif key == "space" then
			TogglePause(not paused)
		elseif key == "f" then
			for i=1,tpu do
				DoTick(i==1)
			end
			TogglePause(true)
		elseif key == "escape" and not winscreen then
			if mainmenu then
				mainmenu = 1
			else
				inmenu = not inmenu
			end
		elseif key == "r" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("lgui")) and not mainmenu then
			RefreshWorld()
		elseif key == "tab" and not puzzle and not mainmenu then
			ToggleSelection()
		elseif key == "c" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("lgui")) and selection.on and not mainmenu then
			CopySelection()
		elseif key == "x" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("lgui")) and selection.on and not mainmenu then
			CutSelection()
		elseif key == "backspace" and selection.on and not mainmenu then
			DeleteSelection()
		elseif key == "v" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("lgui")) and not mainmenu then
			pasting = copied[0] and true
			buttons.paste.color = pasting and {.5,1,.5,1} or {1,1,1,.5}
		elseif (key == "d" or key == "right") and freezecam then
			held = 0
		elseif (key == "a" or key == "left") and freezecam then
			held = 2
		elseif (key == "w" or key == "up") and freezecam then
			held = 3
		elseif (key == "s" or key == "down") and freezecam then
			held = 1
		end
	end
end

function love.mousepressed(x, y, btn) 
	typing = false
	if mainmenu then return end
	newwidth = math.max(newwidth,1)
	newheight = math.max(newheight,1)
	if btn == 1 and not hoveredbutton and not IsBackground(chosen.id) then
		local cx = math.floor((x+cam.x-400*winxm)/cam.zoom)
		local cy = math.floor((y+cam.y-300*winym)/cam.zoom)
		if puzzle then
			if isinitial then
				local p = GetPlaceable(cx,cy)
				if GetCell(cx,cy).id ~= 0 then
					if p == "placeable" or p == "placeableR" or p == "placeableY" or p == "placeableG" or p == "placeableC" or p == "placeableB" or p == "placeableP" then
						draggedcell = GetCell(cx,cy)
						PlaceCell(cx,cy,getempty())
					elseif p == "rotatable"then
						cells[cy][cx].rot = (cells[cy][cx].rot+1)%4
						PlaceCell(cx,cy,cells[cy][cx])
					end
				end
				if type(ModStuff.whenClicked[p]) == "function" then
					ModStuff.whenClicked[p](cells[cy][cx], cx, cy)
				end
			end
		elseif pasting then
			undocells.topush = table.copy(cells)
			undocells.topush.isinitial = isinitial
			for y=0,#copied do
				for x=0,#copied[0] do
					if (chosen.mode ~= "Or" or GetCell(x+cx,y+cy).id == 0) and (chosen.mode ~= "And" or GetCell(x+cx,y+cy).id ~= 0) then
						copied[y][x].lastvars = {x+cx,y+cy,copied[y][x].rot}
						PlaceCell(x+cx,y+cy,table.copy(copied[y][x]))
					end
				end
			end
			placecells = false
			pasting = false
			buttons.paste.color = pasting and {.5,1,.5,1} or {1,1,1,.5}
		else
			local cell = GetCell(cx,cy)
			if selection.on then
				placecells = false
				selection.x,selection.y,selection.w,selection.h = cx,cy,1,1
			elseif cell.id == 165 or cell.id == 166 or cell.id == 175 or cell.id == 198 or cell.id == 235 then
				if chosen.id == 0 then
					if cell.vars[1] then
						cell.vars = {}
						initial[cy][cx].vars = {}
						placecells = false
					end
				else
					cell.vars = {chosen.id,chosen.rot}
					if isinitial then initial[cy][cx].vars = {chosen.id,chosen.rot} end
					placecells = false
				end
			elseif cell.id == 233 then
				if chosen.id == 0 then
					if cell.vars[1] then
						cell.vars = {}
						initial[cy][cx].vars = {}
						placecells = false
					end
				else
					cell.vars = {chosen.id}
					if isinitial then initial[cy][cx].vars = {chosen.id} end
					placecells = false
				end
			elseif cell.id == 0 and chosen.id == 0 and GetPlaceable(cx,cy) then
				erasebg = true
			end
		end
	elseif btn == 2 and not hoveredbutton then
		if pasting then
			pasting = false
			buttons.paste.color = pasting and {.5,1,.5,1} or {1,1,1,.5}
		else
			local cx = math.floor((x+cam.x-400*winxm)/cam.zoom)
			local cy = math.floor((y+cam.y-300*winym)/cam.zoom)
			local cell = GetCell(cx,cy)
			if (cell.id == 165 or cell.id == 166 or cell.id == 175 or cell.id == 198 or cell.id == 233 or cell.id == 235) and cell.vars[1] then
				cell.vars = {}
				if isinitial then initial[cy][cx].vars = {} end
				placecells = false
			elseif (cell.id == 0 or IsBackground(chosen.id)) and GetPlaceable(cx,cy) then
				erasebg = true
			end
		end
	elseif btn == 3 and not hoveredbutton and not puzzle then
		local cx = math.floor((x+cam.x-400*winxm)/cam.zoom)
		local cy = math.floor((y+cam.y-300*winym)/cam.zoom)
		local cell = GetCell(cx,cy)
		SetSelectedCell(cell.id == 0 and GetPlaceable(cx,cy) or cell.id)
		chosen.rot = cell.rot
		if CopyVars(cell.id) then
			for i=1,12 do
				chosen.data[i] = cell.vars[i] or chosen.data[i]
			end
		end
	end
end

function love.mousereleased(x, y, btn)
	if undocells.topush then
		table.insert(undocells,1,undocells.topush)
		if #undocells > maxundo then
			undocells[maxundo+1] = nil
		end
		undocells.topush = nil
	end
	if draggedcell then
		local cx = math.floor((x+cam.x-400*winxm)/cam.zoom)
		local cy = math.floor((y+cam.y-300*winym)/cam.zoom)
		if GetPlaceable(cx,cy) == GetPlaceable(draggedcell.lastvars[1],draggedcell.lastvars[2]) then
			PlaceCell(draggedcell.lastvars[1],draggedcell.lastvars[2],GetCell(cx,cy))
			PlaceCell(cx,cy,draggedcell)
		else
			PlaceCell(draggedcell.lastvars[1],draggedcell.lastvars[2],draggedcell)
		end
	elseif hoveredbutton then
		hoveredbutton.onclick(hoveredbutton)
	end
	placecells = true
	erasebg = false
	draggedcell = nil
	uiscale = newuiscale
end

function love.wheelmoved(x,y)
	if love.keyboard.isDown("lctrl") or love.keyboard.isDown("lgui") then
		chosen.size = math.max(chosen.size+y,1)
	else
		ChangeZoom(y)
	end
end

InitTestMod()
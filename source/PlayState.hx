package;

import flixel.system.replay.MouseRecord;
import haxe.display.Display.EnumFieldOriginKind;
import polymod.backends.PolymodAssetLibrary;
import flixel.util.FlxSpriteUtil;
#if FEATURE_LUAMODCHART
import LuaClass;
#end
import lime.media.openal.AL;
import Song.Event;
import openfl.media.Sound;
#if FEATURE_STEPMANIA
import smTools.SMFile;
#end
#if FEATURE_FILESYSTEM
import sys.io.File;
import Sys;
import sys.FileSystem;
#end
import openfl.ui.KeyLocation;
import openfl.events.Event;
import openfl.system.System;
import haxe.EnumTools;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import Replay.Ana;
import Replay.Analysis;
#if FEATURE_WEBM
import webm.WebmPlayer;
#end
import flixel.input.keyboard.FlxKey;
import haxe.Exception;
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import openfl.utils.AssetType;
import lime.graphics.Image;
import flixel.graphics.FlxGraphic;
import openfl.utils.AssetManifest;
import openfl.utils.AssetLibrary;
import lime.app.Application;
import lime.media.AudioContext;
import lime.media.AudioManager;
import openfl.Lib;
import Section.SwagSection;
import Options;
import Song.SongData;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import flixel.util.FlxDestroyUtil;
#if FEATURE_DISCORD
import Discord.DiscordClient;
#end
// HAXESCRIPT MODCHARTS AS MODDING+
import hscript.Expr;
import hscript.Parser;
import hscript.Interp;

using StringTools;

class PlayState extends MusicBeatState
{
	public static var instance:PlayState = null;

	public static var SONG:SongData;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 0;
	public static var songMultiplier:Float = 1.0;
	public static var weekSong:Int = 0;
	public static var weekScore:Int = 0;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;

	public static var songPosBG:FlxSprite;

	public var visibleCombos:Array<FlxSprite> = [];

	public static var addedBotplay:Bool = false;

	public var visibleNotes:Array<Note> = [];

	public var songPosBar:FlxBar;

	public static var noteskinSprite:FlxAtlasFrames;
	public static var noteskinPixelSprite:BitmapData;
	public static var noteskinPixelSpriteEnds:BitmapData;

	public static var rep:Replay;
	public static var loadRep:Bool = false;
	public static var inResults:Bool = false;

	public static var inDaPlay:Bool = false;

	public static var ratingInDaMove:Bool = false;

	public static var noteBools:Array<Bool> = [false, false, false, false];

	var songLength:Float = 0;
	var kadeEngineWatermark:FlxText;

	#if FEATURE_DISCORD
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	public var vocals:FlxSound;

	public static var isSM:Bool = false;
	#if FEATURE_STEPMANIA
	public static var sm:SMFile;
	public static var pathToSm:String;
	#end

	public static var dad:Character;
	public static var gf:Character;
	public static var boyfriend:Boyfriend;

	public var notes:FlxTypedGroup<Note>;

	public var unspawnNotes:Array<Note> = [];

	public var strumLine:FlxSprite;

	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	public var laneunderlay:FlxSprite;
	public var laneunderlayOpponent:FlxSprite;

	public static var strumLineNotes:FlxTypedGroup<StaticArrow> = null;
	public static var playerStrums:FlxTypedGroup<StaticArrow> = null;
	public static var cpuStrums:FlxTypedGroup<StaticArrow> = null;

	private var camZooming:Bool = false;

	private var curSong:String = "";

	private var gfSpeed:Int = 1;

	public var health:Float = 1; // making public because sethealth doesnt work without it

	private var combo:Int = 0;

	public static var misses:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var campaignSicks:Int = 0;
	public static var campaignGoods:Int = 0;
	public static var campaignBads:Int = 0;
	public static var campaignShits:Int = 0;

	public var accuracy:Float = 0.00;
	public var shownAccuracy:Float = 0;

	private var accuracyDefault:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalNotesHitDefault:Float = 0;
	private var totalPlayed:Int = 0;
	private var ss:Bool = false;

	private var healthBarBG:FlxSprite;

	public var healthBar:FlxBar;

	private var songPositionBar:Float = 0;

	public var generatedMusic:Bool = false;
	public var startingSong:Bool = false;

	public var iconP1:HealthIcon; // making these public again because i may be stupid
	public var iconP2:HealthIcon; // what could go wrong?
	public var camHUD:FlxCamera;
	public var camSustains:FlxCamera;
	public var camNotes:FlxCamera;

	public var camGame:FlxCamera;

	public var mainCam:FlxCamera;

	public var cannotDie = false;

	public static var offsetTesting:Bool = false;

	public var isSMFile:Bool = false;

	var notesHitArray:Array<Date> = [];
	var currentFrames:Int = 0;
	var idleToBeat:Bool = true; // change if bf and dad would idle to the beat of the song
	var idleBeat:Int = 2; // how frequently bf and dad would play their idle animation(1 - every beat, 2 - every 2 beats and so on)
	var forcedToIdle:Bool = false; // change if bf and dad are forced to idle to every (idleBeat) beats of the song
	var allowedToHeadbang:Bool = true; // Will decide if gf is allowed to headbang depending on the song
	var allowedToCheer:Bool = false; // Will decide if gf is allowed to cheer depending on the song

	public var dialogue:Array<String> = ['dad:blah blah blah', 'bf:coolswag'];

	var songName:FlxText;

	var spin:Float;

	var altSuffix:String = "";

	public var currentSection:SwagSection;

	var fc:Bool = true;

	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;

	public static var currentSong = "noneYet";

	public var songScore:Int = 0;
	public var shownSongScore:Int = 0;

	var songScoreDef:Int = 0;
	var scoreTxt:FlxText;
	var judgementCounter:FlxText;
	var replayTxt:FlxText;

	var needSkip:Bool = false;
	var skipActive:Bool = false;
	var skipText:FlxText;
	var skipTo:Float;

	public static var campaignScore:Int = 0;

	public static var theFunne:Bool = true;

	var funneEffect:FlxSprite;
	var inCutscene:Bool = false;
	var usedTimeTravel:Bool = false;

	public static var stageTesting:Bool = false;

	var camPos:FlxPoint;

	public var randomVar = false;

	public static var Stage:Stage;

	public static var repPresses:Int = 0;
	public static var repReleases:Int = 0;

	public static var timeCurrently:Float = 0;
	public static var timeCurrentlyR:Float = 0;

	// Will fire once to prevent debug spam messages and broken animations
	private var triggeredAlready:Bool = false;

	// Per song additive offset
	public static var songOffset:Float = 0;

	// BotPlay text
	private var botPlayState:FlxText;
	// Replay shit
	private var saveNotes:Array<Dynamic> = [];
	private var saveJudge:Array<String> = [];
	private var replayAna:Analysis = new Analysis(); // replay analysis

	public static var highestCombo:Int = 0;

	public var executeModchart = false;

	// Animation common suffixes
	private var dataSuffix:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
	private var dataColor:Array<String> = ['purple', 'blue', 'green', 'red'];

	public static var startTime = 0.0;

	// API stuff
	// WTF WHERE IS IT?
	// MAKING DEEZ PUBLIC TO MAKE COMPLEX ACCURACY WORK
	public var msTiming:Float;

	public var updatedAcc:Bool = false;

	// SONG MULTIPLIER STUFF
	var speedChanged:Bool = false;

	public var previousRate:Float = songMultiplier;

	public var scrollMult:Float = 1.0;

	public var songFixedName:String = SONG.songName;

	// SCROLL SPEED
	public var scrollSpeed(default, set):Float = 1.0;
	public var scrollTween:FlxTween;

	// VARS FOR LUA DUE TO FUCKING BUGGED BOOLS
	public var LuaDownscroll:Bool = FlxG.save.data.downscroll;
	public var LuaMidscroll:Bool = FlxG.save.data.middleScroll;
	public var zoomAllowed:Bool = FlxG.save.data.camzoom;
	public var LuaColours:Bool = FlxG.save.data.colour;
	public var LuaStepMania:Bool = FlxG.save.data.stepMania;
	public var LuaOpponent:Bool = PlayStateChangeables.opponentMode;

	public var bigDickFutaOMGIloveItMakemeCumPleaseIwantUtoFillMyBellyWithUrStickyStuffPLEASE:Int = FlxG.save.data.noteskin; // Uuuh... u ok bro?

	var lightsWentBRRR:FlxSprite;
	var littleLight:FlxSprite;

	public var pos:Float = 0;

	var lightsWentBRRRnt:FlxSprite;

	var opponentAllowedtoAnim:Bool = true;

	var bfAllowedtoAnim:Bool = true;

	public static var leMirror:Bool = false;

	var conalep_pc:FlxSprite;

	// CAMERA MOVING STUFF
	var camX:Int = 0;
	var camY:Int = 0;

	// Combo and Rating vars.
	var rating:FlxSprite = new FlxSprite();
	var comboSprGroup:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();

	// Shown Accuracy Mode text
	var accText:FlxText;

	var doof = null;

	public function addObject(object:FlxBasic)
	{
		add(object);
	}

	public function removeObject(object:FlxBasic)
	{
		remove(object);
	}

	override public function create()
	{
		Main.dumpCache();
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
		FlxG.mouse.visible = false;
		instance = this;

		GameplayCustomizeState.freeplayBf = 'bf';
		GameplayCustomizeState.freeplayDad = 'dad';
		GameplayCustomizeState.freeplayGf = 'gf';
		GameplayCustomizeState.freeplayNoteStyle = 'normal';
		GameplayCustomizeState.freeplayStage = 'stage';
		GameplayCustomizeState.freeplaySong = 'bopeebo';
		GameplayCustomizeState.freeplayWeek = 1;

		switch (SONG.songId)
		{
			case 'bopeebo':
				songFixedName = "Bopeebo";
			case 'fresh':
				songFixedName = "Fresh!";
			case 'dadbattle':
				songFixedName = "Dad Battle";
			case "spookeez":
				songFixedName = "Spookeez!";
			case "south":
				songFixedName = "South";
			case "monster":
				songFixedName = "Monster...";
			case "pico":
				songFixedName = "Pico";
			case "philly":
				songFixedName = "Philly Noice";
			case "blammed":
				songFixedName = "Blammed";
			case "high":
				songFixedName = "High!";
			case "cocoa":
				songFixedName = "Cocoa";
			case "eggnog":
				songFixedName = "EGGnog";
			case "winter-horroland":
				songFixedName = "Winter Horroland...";
			case "senpai":
				songFixedName = "Hentai! Uh I mean Senpai!";
			case "roses":
				songFixedName = "Roses...";
			case "thorns":
				songFixedName = "Thorns!";
			case 'bi':
				songFixedName = "Bi ???";
			case 'made-in-love':
				songFixedName = "Made In Love";
			case 'sayonara-planet-wars':
				songFixedName = "Sayonara Planet Wars!";
			case 'fin4le':
				songFixedName = "F1n4le";
		}

		previousRate = songMultiplier - 0.05;

		if (previousRate < 1.00)
			previousRate = 1;

		if (FlxG.save.data.fpsCap > 300)
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(300);

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		inDaPlay = true;

		if (currentSong != SONG.songName)
		{
			currentSong = SONG.songName;
			Main.dumpCache();
		}

		sicks = 0;
		bads = 0;
		shits = 0;
		goods = 0;

		misses = 0;

		highestCombo = 0;
		repPresses = 0;
		repReleases = 0;
		inResults = false;

		PlayStateChangeables.useDownscroll = FlxG.save.data.downscroll;
		PlayStateChangeables.safeFrames = FlxG.save.data.frames;

		if (FlxG.save.data.scrollSpeed == 1) // YOOO WTFFFFF IS THIS FUCKING THING A FIX???
		{
			scrollSpeed = 25 * songMultiplier;
			new FlxTimer().start(0.01, function(tmr)
			{
				scrollSpeed = SONG.speed * songMultiplier;
			});
		}
		else
		{
			scrollSpeed = 25 * songMultiplier;
			new FlxTimer().start(0.01, function(tmr)
			{
				scrollSpeed = FlxG.save.data.scrollSpeed * songMultiplier;
			});
		}

		if (!isStoryMode)
		{
			PlayStateChangeables.modchart = FlxG.save.data.modcharts;
			PlayStateChangeables.botPlay = FlxG.save.data.botplay;
			PlayStateChangeables.opponentMode = FlxG.save.data.opponent;
			PlayStateChangeables.mirrorMode = FlxG.save.data.mirror;
			PlayStateChangeables.holds = FlxG.save.data.sustains;
			PlayStateChangeables.healthDrain = FlxG.save.data.hdrain;
			PlayStateChangeables.healthGain = FlxG.save.data.hgain;
			PlayStateChangeables.healthLoss = FlxG.save.data.hloss;
			PlayStateChangeables.practiceMode = FlxG.save.data.practice;
			PlayStateChangeables.skillIssue = FlxG.save.data.noMisses;
		}
		else
		{
			PlayStateChangeables.modchart = false;
			PlayStateChangeables.botPlay = false;
			PlayStateChangeables.opponentMode = false;
			PlayStateChangeables.mirrorMode = false;
			PlayStateChangeables.holds = true;
			PlayStateChangeables.healthDrain = false;
			PlayStateChangeables.healthGain = 1;
			PlayStateChangeables.healthLoss = 1;
			PlayStateChangeables.practiceMode = false;
			PlayStateChangeables.skillIssue = false;
		}
		// FlxG.save.data.optimize = FlxG.save.data.optimize;
		PlayStateChangeables.zoom = FlxG.save.data.zoom;

		removedVideo = false;

		#if FEATURE_LUAMODCHART
		// TODO: Refactor this to use OpenFlAssets.
		executeModchart = FileSystem.exists(Paths.lua('songs/${PlayState.SONG.songId}/modchart')) && PlayStateChangeables.modchart;
		if (isSM)
			executeModchart = FileSystem.exists(pathToSm + "/modchart.lua") && PlayStateChangeables.modchart;
		/*if (executeModchart)
			FlxG.save.data.optimize = false; */
		#end
		#if !cpp
		executeModchart = false; // FORCE disable for non cpp targets
		#end

		Debug.logInfo('Searching for mod chart? ($executeModchart) at ${Paths.lua('songs/${PlayState.SONG.songId}/modchart')}');

		if (SONG.songId == 'fin4le')
		{
			if (storyDifficulty == 0)
			{
				storyDifficulty = 4;
			}
		}

		// EXPERIMENTAL HAXESCRIPT MODCHART
		#if FEATURE_FILESYSTEM
		if (FileSystem.exists(Sys.getCwd() + 'assets/data/${SONG.song.toLowerCase()}/haxeModchart.hx') && PlayStateChangeables.modchart)
		{
			var expr = Paths.getHaxeScript(SONG.song.toLowerCase());
			var parser = new hscript.Parser();
			var ast = parser.parseString(expr);
			var interp = new hscript.Interp();
			trace(interp.execute(ast));
		}
		#end

		/*if (executeModchart)
			songMultiplier = 1; */

		#if FEATURE_DISCORD
		// Making difficulty text for Discord Rich Presence.
		storyDifficultyText = CoolUtil.difficultyFromInt(storyDifficulty);

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: Week " + storyWeek;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;

		// Updating Discord Rich Presence
		if (FlxG.save.data.discordMode != 0)
			DiscordClient.changePresence(songFixedName + " (" + storyDifficultyText + " " + songMultiplier + "x" + ") "
				+ Ratings.GenerateComboRank(accuracy) + " " + Ratings.GenerateLetterRank(accuracy),
				"\nScr: " + songScore + " ("
				+ HelperFunctions.truncateFloat(accuracy, 2) + "%)" + " | Misses: " + misses, iconRPC);
		else
			DiscordClient.changePresence("Playing " + songFixedName + " (" + storyDifficultyText + " " + songMultiplier + "x" + ") ", "", iconRPC);
		#end

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camSustains = new FlxCamera();
		camSustains.bgColor.alpha = 0;
		camNotes = new FlxCamera();
		camNotes.bgColor.alpha = 0;
		mainCam = new FlxCamera();
		mainCam.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camSustains);
		FlxG.cameras.add(camNotes);
		FlxG.cameras.add(mainCam);

		camHUD.zoom = PlayStateChangeables.zoom;
		FlxCamera.defaultCameras = [camGame];
		PsychTransition.nextCamera = mainCam;

		persistentUpdate = persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial', '');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		Conductor.bpm = SONG.bpm;

		if (SONG.eventObjects == null)
		{
			SONG.eventObjects = [new Song.Event("Init BPM", 0, SONG.bpm, "BPM Change")];
		}

		TimingStruct.clearTimings();

		var currentIndex = 0;
		for (i in SONG.eventObjects)
		{
			if (i.type == "BPM Change")
			{
				var beat:Float = i.position;

				var endBeat:Float = Math.POSITIVE_INFINITY;

				var bpm = i.value * songMultiplier;

				TimingStruct.addTiming(beat, bpm, endBeat, 0); // offset in this case = start time since we don't have a offset

				if (currentIndex != 0)
				{
					var data = TimingStruct.AllTimings[currentIndex - 1];
					data.endBeat = beat;
					data.length = ((data.endBeat - data.startBeat) / (data.bpm / 60)) / songMultiplier;
					var step = ((60 / data.bpm) * 1000) / 4;
					TimingStruct.AllTimings[currentIndex].startStep = Math.floor((((data.endBeat / (data.bpm / 60)) * 1000) / step) / songMultiplier);
					TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length / songMultiplier;
				}

				currentIndex++;
			}
		}

		recalculateAllSectionTimes();

		trace('INFORMATION ABOUT WHAT U PLAYIN WIT:\nFRAMES: ' + PlayStateChangeables.safeFrames + '\nZONE: ' + Conductor.safeZoneOffset + '\nTS: '
			+ Conductor.timeScale + '\nBotPlay : ' + PlayStateChangeables.botPlay);

		// if the song has dialogue, so we don't accidentally try to load a nonexistant file and crash the game
		if (Paths.doesTextAssetExist(Paths.txt('data/songs/${PlayState.SONG.songId}/dialogue')))
		{
			dialogue = CoolUtil.coolTextFile(Paths.txt('data/songs/${PlayState.SONG.songId}/dialogue'));
			inCutscene = true;
		}
		else
		{
			inCutscene = false;
		}

		// defaults if no stage was found in chart
		var stageCheck:String = 'stage';

		// If the stage isn't specified in the chart, we use the story week value.
		if (SONG.stage == null)
		{
			switch (storyWeek)
			{
				case 0:
					stageCheck = 'voltexStage';
				case 2:
					stageCheck = 'halloween';
				case 3:
					stageCheck = 'philly';
				case 4:
					stageCheck = 'limo';
				case 5:
					if (SONG.songId == 'winter-horrorland')
					{
						stageCheck = 'mallEvil';
					}
					else
					{
						stageCheck = 'mall';
					}
				case 6:
					if (SONG.songId == 'thorns')
					{
						stageCheck = 'schoolEvil';
					}
					else
					{
						stageCheck = 'school';
					}
					// i should check if its stage (but this is when none is found in chart anyway)
			}
		}
		else
		{
			stageCheck = SONG.stage;
		}

		if (isStoryMode)
			songMultiplier = 1;

		// defaults if no gf was found in chart
		var gfCheck:String = 'gf';

		if (SONG.gfVersion == null)
		{
			switch (storyWeek)
			{
				case 4:
					gfCheck = 'gf-car';
				case 5:
					gfCheck = 'gf-christmas';
				case 6:
					gfCheck = 'gf-pixel';
			}
		}
		else
		{
			gfCheck = SONG.gfVersion;
		}

		if (!stageTesting || !FlxG.save.data.optimize)
		{
			gf = new Character(400, 130, gfCheck);

			if (gf.frames == null)
			{
				#if debug
				FlxG.log.warn(["Couldn't load gf: " + gfCheck + ". Loading default gf"]);
				#end
				gf = new Character(400, 130, 'gf');
			}

			boyfriend = new Boyfriend(770, 450, SONG.player1);

			if (boyfriend.frames == null)
			{
				#if debug
				FlxG.log.warn(["Couldn't load boyfriend: " + SONG.player1 + ". Loading default boyfriend"]);
				#end
				boyfriend = new Boyfriend(770, 450, 'bf');
			}

			dad = new Character(100, 100, SONG.player2);

			if (dad.frames == null)
			{
				#if debug
				FlxG.log.warn(["Couldn't load opponent: " + SONG.player2 + ". Loading default opponent"]);
				#end
				dad = new Character(100, 100, 'dad');
			}
		}

		if (!stageTesting)
			Stage = new Stage(SONG.stage);

		var positions = Stage.positions[Stage.curStage];
		if (positions != null && !stageTesting)
		{
			for (char => pos in positions)
				for (person in [boyfriend, gf, dad])
					if (person.curCharacter == char)
						person.setPosition(pos[0], pos[1]);
		}

		for (i in Stage.toAdd)
		{
			add(i);
		}

		if (!FlxG.save.data.optimize)
			for (index => array in Stage.layInFront)
			{
				switch (index)
				{
					case 0:
						add(gf);
						gf.scrollFactor.set(0.95, 0.95);
						for (bg in array)
							add(bg);
					case 1:
						add(dad);
						for (bg in array)
							add(bg);
					case 2:
						add(boyfriend);
						for (bg in array)
							add(bg);
				}
			}

		gf.x += gf.charPos[0];
		gf.y += gf.charPos[1];
		dad.x += dad.charPos[0];
		dad.y += dad.charPos[1];
		boyfriend.x += boyfriend.charPos[0];
		boyfriend.y += boyfriend.charPos[1];

		camPos = new FlxPoint(dad.getGraphicMidpoint().x + dad.camPos[0], dad.getGraphicMidpoint().y + dad.camPos[1]);

		switch (Stage.curStage)
		{
			case 'halloween':
				camPos = new FlxPoint(gf.getMidpoint().x + dad.camPos[0], gf.getMidpoint().y + dad.camPos[1]);
			case 'voltexStage':
				camPos = new FlxPoint(gf.getMidpoint().x + dad.camPos[0], gf.getMidpoint().y + dad.camPos[1]);
			default:
				camPos = new FlxPoint(dad.getGraphicMidpoint().x + dad.camPos[0], dad.getGraphicMidpoint().y + dad.camPos[1]);
		}

		if (dad.replacesGF)
		{
			if (!stageTesting)
				dad.setPosition(gf.x, gf.y);
			gf.visible = false;
			if (isStoryMode)
			{
				camPos.x += 600;
				tweenCamIn();
			}
		}

		if (dad.hasTrail)
		{
			if (FlxG.save.data.distractions)
			{
				// trailArea.scrollFactor.set();
				if (!FlxG.save.data.optimize)
				{
					var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
					// evilTrail.changeValuesEnabled(false, false, false, false);
					// evilTrail.changeGraphic()
					add(evilTrail);
				}
				// evilTrail.scrollFactor.set(1.1, 1.1);
			}
		}
		if (!FlxG.save.data.optimize && FlxG.save.data.background)
			Stage.update(0);

		if (loadRep)
		{
			FlxG.watch.addQuick('rep rpesses', repPresses);
			FlxG.watch.addQuick('rep releases', repReleases);
			// FlxG.watch.addQuick('Queued',inputsQueued);

			PlayStateChangeables.useDownscroll = rep.replay.isDownscroll;
			PlayStateChangeables.safeFrames = rep.replay.sf;
			PlayStateChangeables.botPlay = true;
		}

		trace('uh ' + PlayStateChangeables.safeFrames);

		trace("SF CALC: " + Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));

		if (inCutscene && isStoryMode)
		{
			doof = new DialogueBox(false, dialogue);
			// doof.x += 70;
			// doof.y = FlxG.height * 0.5;
			doof.scrollFactor.set();
			doof.finishThing = startCountdown;
		}

		// if (songMultiplier == 1)
		// {
		var firstNoteTime = Math.POSITIVE_INFINITY;
		var playerTurn = false;
		for (index => section in SONG.notes)
		{
			if (section.sectionNotes.length > 0 && !isSM)
			{
				if (section.startTime / songMultiplier > 5000 / songMultiplier)
				{
					needSkip = true;
					skipTo = (section.startTime - 1000);
				}
				break;
			}
			else if (isSM)
			{
				for (note in section.sectionNotes)
				{
					if (note[0] < firstNoteTime)
					{
						if (!FlxG.save.data.optimize)
						{
							firstNoteTime = note[0];
							if (note[1] > 3)
								playerTurn = true;
							else
								playerTurn = false;
						}
						else if (note[1] > 3)
						{
							firstNoteTime = note[0];
						}
					}
				}
				if (index + 1 == SONG.notes.length)
				{
					var timing = ((!playerTurn && !FlxG.save.data.optimize) ? firstNoteTime : TimingStruct.getTimeFromBeat(TimingStruct.getBeatFromTime(firstNoteTime)
						- 4)) / Math.pow(songMultiplier, 2);
					if (timing > 5000 / songMultiplier)
					{
						needSkip = true;
						skipTo = (timing - 1000);
					}
				}
			}
		}
		// }

		Conductor.songPosition = -5000;
		Conductor.rawPosition = Conductor.songPosition;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		if (PlayStateChangeables.useDownscroll)
			strumLine.y = FlxG.height - 165;

		laneunderlayOpponent = new FlxSprite(0, 0).makeGraphic(110 * 4 + 50, FlxG.height * 2);

		laneunderlayOpponent.alpha = FlxG.save.data.laneTransparency;

		laneunderlayOpponent.color = FlxColor.BLACK;
		laneunderlayOpponent.scrollFactor.set();

		laneunderlay = new FlxSprite(0, 0).makeGraphic(110 * 4 + 50, FlxG.height * 2);
		laneunderlay.alpha = FlxG.save.data.laneTransparency;

		if (storyPlaylist.length >= 3)
		{
			if (inCutscene)
			{
				laneunderlayOpponent.alpha = 0;
				laneunderlay.alpha = 0;
			}
		}

		laneunderlay.color = FlxColor.BLACK;
		laneunderlay.scrollFactor.set();

		if (FlxG.save.data.laneUnderlay)
		{
			if (!FlxG.save.data.middleScroll || executeModchart)
			{
				add(laneunderlayOpponent);
				laneunderlayOpponent.updateHitbox();
			}
			add(laneunderlay);
			laneunderlay.updateHitbox();
		}

		strumLineNotes = new FlxTypedGroup<StaticArrow>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<StaticArrow>();
		cpuStrums = new FlxTypedGroup<StaticArrow>();

		#if !html5
		noteskinPixelSprite = NoteskinHelpers.generatePixelSprite(FlxG.save.data.noteskin);
		noteskinSprite = NoteskinHelpers.generateNoteskinSprite(FlxG.save.data.noteskin);
		noteskinPixelSpriteEnds = NoteskinHelpers.generatePixelSprite(FlxG.save.data.noteskin, true);
		#end

		if (!FlxG.save.data.middleScroll || executeModchart)
		{
			generateStaticArrows(0);
			generateStaticArrows(1);
		}
		else
		{
			if (!executeModchart)
			{
				if (!PlayStateChangeables.opponentMode)
					generateStaticArrows(1);
				else
					generateStaticArrows(0);
			}
		}

		// Update lane underlay positions AFTER static arrows :)
		laneunderlay.x = playerStrums.members[0].x - 25;

		if (!FlxG.save.data.optimize && !FlxG.save.data.middleScroll || executeModchart)
		{
			laneunderlayOpponent.x = cpuStrums.members[0].x - 25;
		}

		laneunderlay.screenCenter(Y);
		laneunderlayOpponent.screenCenter(Y);

		if (inCutscene && storyPlaylist.length >= 3)
		{
			removeStaticArrows();
		}

		// startCountdown();

		if (SONG.songId == null)
			trace('song is null???');
		else
			trace('song looks gucci');

		generateSong(SONG.songId);

		#if FEATURE_LUAMODCHART
		if (executeModchart)
		{
			luaModchart = ModchartState.createModchartState();
			luaModchart.executeState('start', [PlayState.SONG.songId]);
		}
		#end

		#if FEATURE_LUAMODCHART
		if (executeModchart)
		{
			var window = new LuaWindow();
			new LuaCamera(FlxG.camera, "camGame").Register(ModchartState.lua);
			new LuaCamera(camHUD, "camHUD").Register(ModchartState.lua);
			new LuaCamera(camSustains, "camSustains").Register(ModchartState.lua);
			new LuaCamera(camNotes, "camNotes").Register(ModchartState.lua);
			new LuaCamera(mainCam, "mainCam").Register(ModchartState.lua);
			new LuaCharacter(dad, "dad").Register(ModchartState.lua);
			new LuaCharacter(gf, "gf").Register(ModchartState.lua);
			new LuaCharacter(boyfriend, "boyfriend").Register(ModchartState.lua);
		}
		#end

		var index = 0;

		if (startTime != 0)
		{
			var toBeRemoved = [];
			for (i in 0...unspawnNotes.length)
			{
				var dunceNote:Note = unspawnNotes[i];

				if (dunceNote.strumTime <= startTime)
					toBeRemoved.push(dunceNote);
			}

			for (i in toBeRemoved)
				unspawnNotes.remove(i);

			Debug.logTrace("Removed " + toBeRemoved.length + " cuz of start time");
		}

		for (i in 0...unspawnNotes.length)
			if (unspawnNotes[i].strumTime < startTime)
				unspawnNotes.remove(unspawnNotes[i]);

		trace('generated');

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = Stage.camZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		if (PlayStateChangeables.useDownscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		// healthBar
		var accMode:String = "None";
		if (FlxG.save.data.accuracyMod == 0)
			accMode = "Accurate";
		else if (FlxG.save.data.accuracyMod == 1)
			accMode = "Complex";

		// Add Kade Engine watermark
		kadeEngineWatermark = new FlxText(4, FlxG.height * 0.9
			+ 45, 0,
			SONG.songName
			+ (FlxMath.roundDecimal(songMultiplier, 2) != 1.00 ? " (" + FlxMath.roundDecimal(songMultiplier, 2) + "x)" : "")
			+ " - "
			+ CoolUtil.difficultyFromInt(storyDifficulty),
			16);
		kadeEngineWatermark.setFormat(Paths.font("aironec.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		kadeEngineWatermark.scrollFactor.set();
		kadeEngineWatermark.antialiasing = FlxG.save.data.antialiasing;
		add(kadeEngineWatermark);

		// ACCURACY WATERMARK

		accText = new FlxText(4, FlxG.height * 0.9 + 45 - 20, 0, "Accuracy Mode: " + accMode, 16);
		accText.scrollFactor.set();
		accText.setFormat(Paths.font("aironec.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		accText.antialiasing = FlxG.save.data.antialiasing;
		add(accText);

		scoreTxt = new FlxText(FlxG.width / 2 - 235, healthBarBG.y + 50, 0, "", 20);
		scoreTxt.screenCenter(X);
		scoreTxt.scrollFactor.set();
		scoreTxt.setFormat(Paths.font("aironec.ttf"), 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		/*scoreTxt.text = Ratings.CalculateRanking(songScore, songScoreDef, nps, maxNPS,
			(FlxG.save.data.roundAccuracy ? FlxMath.roundDecimal(accuracy, 0) : accuracy)); */
		if (!FlxG.save.data.healthBar)
			scoreTxt.y = healthBarBG.y;
		scoreTxt.visible = false;
		scoreTxt.antialiasing = FlxG.save.data.antialiasing;
		add(scoreTxt);

		judgementCounter = new FlxText(20, 0, 0, "", 20);
		judgementCounter.setFormat(Paths.font("aironec.ttf"), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		judgementCounter.borderSize = 2;
		judgementCounter.borderQuality = 2;
		judgementCounter.scrollFactor.set();
		judgementCounter.cameras = [camHUD];
		judgementCounter.screenCenter(Y);
		judgementCounter.antialiasing = FlxG.save.data.antialiasing;
		// judgementCounter.text = 'Sicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}\nMisses: ${misses}';
		if (FlxG.save.data.judgementCounter)
		{
			add(judgementCounter);
		}

		replayTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0, "REPLAY",
			20);
		replayTxt.setFormat(Paths.font("aironec.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		replayTxt.borderSize = 4;
		replayTxt.borderQuality = 2;
		replayTxt.scrollFactor.set();
		replayTxt.cameras = [camHUD];
		if (loadRep)
		{
			add(replayTxt);
		}
		// Literally copy-paste of the above, fu
		botPlayState = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0,
			"BOTPLAY", 20);
		botPlayState.setFormat(Paths.font("aironec.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botPlayState.scrollFactor.set();
		botPlayState.borderSize = 4;
		botPlayState.borderQuality = 2;
		botPlayState.cameras = [camHUD];
		if (PlayStateChangeables.botPlay && !loadRep)
			add(botPlayState);

		addedBotplay = PlayStateChangeables.botPlay;

		iconP1 = new HealthIcon(boyfriend.curCharacter, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);

		iconP2 = new HealthIcon(dad.curCharacter, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);

		if (FlxG.save.data.healthBar)
		{
			add(healthBarBG);
			add(healthBar);
			add(iconP1);
			add(iconP2);

			if (FlxG.save.data.colour)
				healthBar.createFilledBar(dad.barColor, boyfriend.barColor);
			else
				healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		}

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		laneunderlay.cameras = [camHUD];
		laneunderlayOpponent.cameras = [camHUD];

		if (inCutscene && isStoryMode)
			doof.cameras = [camHUD];
		kadeEngineWatermark.cameras = [camHUD];
		accText.cameras = [camHUD];

		startingSong = true;

		trace('starting');

		if (!FlxG.save.data.optimize)
		{
			dad.dance();
			boyfriend.dance();
			gf.dance();
		}

		if (isStoryMode)
		{
			switch (StringTools.replace(curSong, " ", "-").toLowerCase())
			{
				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(camGame, {zoom: Stage.camZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});
				case 'senpai':
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);
				case 'thorns':
					schoolIntro(doof);
				case 'made-in-love':
					coolIntro(doof);
				case 'sayonara-planet-wars', 'i':
					coolIntro(doof, false);
				default:
					new FlxTimer().start(0.5, function(timer)
					{
						startCountdown();
					});
			}
		}
		else
		{
			new FlxTimer().start(0.5, function(timer)
			{
				startCountdown();
			});
		}

		if (!loadRep)
			rep = new Replay("na");

		// This allow arrow key to be detected by flixel. See https://github.com/HaxeFlixel/flixel/issues/2190
		FlxG.keys.preventDefaultKeys = [];
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, releaseInput);
		if (!FlxG.save.data.optimize && FlxG.save.data.background && FlxG.save.data.distractions)
		{
			if (SONG.songId == 'i' && Stage.curStage == 'voltexStage')
			{
				lightsWentBRRR = new FlxSprite();
				lightsWentBRRR.frames = Paths.getSparrowAtlas('Sex', 'shared');
				lightsWentBRRR.animation.addByPrefix('Sex', 'sex', Std.int(60 * songMultiplier), false);
				lightsWentBRRR.scrollFactor.set();
				lightsWentBRRR.updateHitbox();
				lightsWentBRRR.screenCenter();
				lightsWentBRRR.cameras = [mainCam];
				littleLight = new FlxSprite();
				littleLight.frames = Paths.getSparrowAtlas('Sex2', 'shared');
				littleLight.animation.addByPrefix('Sex2', 'sex 2, the squeakquel', Std.int(60 * songMultiplier), false);
				littleLight.scrollFactor.set();
				littleLight.updateHitbox();
				littleLight.screenCenter();
				littleLight.cameras = [mainCam];
				lightsWentBRRRnt = new FlxSprite();
				lightsWentBRRRnt.frames = Paths.getSparrowAtlas('Sex3', 'shared');
				lightsWentBRRRnt.animation.addByPrefix('Sex3', 'sex 3, the enemy returns', Std.int(60 * songMultiplier), false);
				lightsWentBRRRnt.scrollFactor.set();
				lightsWentBRRRnt.updateHitbox();
				lightsWentBRRRnt.screenCenter();
				lightsWentBRRRnt.cameras = [mainCam];
				lightsWentBRRR.alpha = 0;
				littleLight.alpha = 0;
				lightsWentBRRRnt.alpha = 0;
				add(lightsWentBRRRnt);
				add(lightsWentBRRR);
				add(littleLight);
			}
		}
		else if (!FlxG.save.data.optimize && FlxG.save.data.background && !FlxG.save.data.distractions)
		{
			if (SONG.songId == 'i' && Stage.curStage == 'voltexStage')
			{
				conalep_pc = new FlxSprite().makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				conalep_pc.screenCenter();
				conalep_pc.cameras = [mainCam];
				conalep_pc.alpha = 0;
				add(conalep_pc);
			}
		}

		// AFTER EVERYTHING LOAD DESTROY EVERYTHING TO SAVE MEMORY IN OPTIMIZED MOD
		if (FlxG.save.data.optimize)
		{
			allowedToCheer = false;
			allowedToHeadbang = false;
			boyfriend.kill();
			gf.destroy();
			dad.kill();
			boyfriend.destroy();
			gf.destroy();
			dad.destroy();
			for (i in Stage.toAdd)
			{
				remove(i, true);
				i.kill();
				i.destroy();
			}
		}

		if (Stage.curStage == 'voltexStage')
		{
			allowedToCheer = false;
			allowedToHeadbang = false;
			remove(gf);
			gf.kill();
			gf.destroy();
		}

		if (!FlxG.save.data.background)
		{
			for (i in Stage.toAdd)
			{
				remove(i, true);
				i.kill();
				i.destroy();
			}
		}

		super.create();
		Paths.clearUnusedMemory();

		rating.alpha = 0;
		rating.cameras = [camHUD];
		add(rating);
		add(comboSprGroup);
	}

	function coolIntro(?dialogueBox:DialogueBox, ?fadeTween:Bool = true):Void
	{
		if (fadeTween)
		{
			if (storyPlaylist.length >= 3 || (storyWeek == 1))
				mainCam.fade(FlxColor.BLACK, 3, true);
		}
		new FlxTimer().start(fadeTween ? 3 : 0.5, function(tmr:FlxTimer)
		{
			if (dialogueBox != null)
			{
				inCutscene = true;
				add(dialogueBox);
			}
			else
			{
				inCutscene = false;
				if (!songStarted)
					startCountdown();
				else
					endSong();
			}
		});
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (PlayState.SONG.songId == 'roses' || PlayState.SONG.songId == 'thorns')
		{
			remove(black);

			if (PlayState.SONG.songId == 'thorns')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (PlayState.SONG.songId == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;
	var luaWiggles:Array<WiggleEffect> = [];

	#if FEATURE_LUAMODCHART
	public static var luaModchart:ModchartState = null;
	#end

	function set_scrollSpeed(value:Float):Float // STOLEN FROM PSYCH ENGINE ONLY SPRITE SCALING PART.
	{
		speedChanged = true;
		if (generatedMusic)
		{
			var ratio:Float = value / scrollSpeed;
			for (note in notes)
			{
				if (note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
				{
					note.scale.y *= ratio;
					note.updateHitbox();
				}
			}
			for (note in unspawnNotes)
			{
				if (note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
				{
					note.scale.y *= ratio;
					note.updateHitbox();
				}
			}
		}
		scrollSpeed = value;
		return value;
	}

	function startCountdown():Void
	{
		if (inCutscene && storyPlaylist.length >= 3)
		{
			FlxTween.tween(laneunderlay, {alpha: FlxG.save.data.laneTransparency}, 0.75, {ease: FlxEase.bounceOut});
			if (!FlxG.save.data.middleScroll || executeModchart)
			{
				FlxTween.tween(laneunderlayOpponent, {alpha: FlxG.save.data.laneTransparency}, 0.75, {ease: FlxEase.bounceOut});
				generateStaticArrows(0);
				generateStaticArrows(1);
			}
			else
			{
				if (!executeModchart)
				{
					if (!PlayStateChangeables.opponentMode)
						generateStaticArrows(1);
					else
						generateStaticArrows(0);
				}
			}
		}
		inCutscene = false;

		// appearStaticArrows();

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		if (FlxG.sound.music.playing)
			FlxG.sound.music.stop();
		if (vocals != null)
			vocals.stop();

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start((Conductor.crochet / 1000), function(tmr:FlxTimer)
		{
			// this just based on beatHit stuff but compact
			if (!FlxG.save.data.optimize)
			{
				if (allowedToHeadbang && swagCounter % gfSpeed == 0)
					gf.dance();

				if (swagCounter % idleBeat == 0)
				{
					if (idleToBeat && !boyfriend.animation.curAnim.name.endsWith("miss"))
						boyfriend.dance(forcedToIdle);
					if (idleToBeat)
						dad.dance(forcedToIdle);
				}
				else if (swagCounter % idleBeat != 0)
				{
					if (boyfriend.isDancing && !boyfriend.animation.curAnim.name.endsWith("miss"))
						boyfriend.dance();
					if (dad.isDancing)
						dad.dance();
				}
			}

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('pixel', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var week6Bullshit:String = null;

			if (SONG.noteStyle == 'pixel')
			{
				introAlts = introAssets.get('pixel');
				altSuffix = '-pixel';
				week6Bullshit = 'week6';
			}

			if (SONG.songId != 'fin4le')
			{
				switch (swagCounter)

				{
					case 0:
						FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
					case 1:
						var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0], week6Bullshit));
						ready.scrollFactor.set();
						ready.scale.set(0.7, 0.7);
						ready.cameras = [camHUD];
						ready.updateHitbox();

						if (SONG.noteStyle == 'pixel')
							ready.setGraphicSize(Std.int(ready.width * CoolUtil.daPixelZoom));

						ready.screenCenter();
						add(ready);
						FlxTween.tween(ready, {alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								ready.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
					case 2:
						var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1], week6Bullshit));
						set.scrollFactor.set();
						set.scale.set(0.7, 0.7);
						if (SONG.noteStyle == 'pixel')
							set.setGraphicSize(Std.int(set.width * CoolUtil.daPixelZoom));
						set.cameras = [camHUD];
						set.screenCenter();
						add(set);
						FlxTween.tween(set, {alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								set.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
					case 3:
						var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2], week6Bullshit));
						go.scrollFactor.set();
						go.scale.set(0.7, 0.7);
						go.cameras = [camHUD];
						if (SONG.noteStyle == 'pixel')
							go.setGraphicSize(Std.int(go.width * CoolUtil.daPixelZoom));

						go.updateHitbox();

						go.screenCenter();
						add(go);
						FlxTween.tween(go, {alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								go.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
				}
			}
			swagCounter += 1;
		}, 4);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	private function getKey(charCode:Int):String
	{
		for (key => value in FlxKey.fromStringMap)
		{
			if (charCode == value)
				return key;
		}
		return null;
	}

	var keys = [false, false, false, false];

	private function releaseInput(evt:KeyboardEvent):Void // handles releases
	{
		@:privateAccess
		var key = FlxKey.toStringMap.get(evt.keyCode);

		var binds:Array<String> = [
			FlxG.save.data.leftBind,
			FlxG.save.data.downBind,
			FlxG.save.data.upBind,
			FlxG.save.data.rightBind
		];

		var data = -1;

		switch (evt.keyCode) // arrow keys
		{
			case 37:
				data = 0;
			case 40:
				data = 1;
			case 38:
				data = 2;
			case 39:
				data = 3;
		}

		for (i in 0...binds.length) // binds
		{
			if (binds[i].toLowerCase() == key.toLowerCase())
				data = i;
		}

		if (data == -1)
			return;

		keys[data] = false;
	}

	public var closestNotes:Array<Note> = [];

	private function handleInput(evt:KeyboardEvent):Void
	{ // this actually handles press inputs

		if (PlayStateChangeables.botPlay || loadRep || paused)
			return;

		// first convert it from openfl to a flixel key code
		// then use FlxKey to get the key's name based off of the FlxKey dictionary
		// this makes it work for special characters

		@:privateAccess
		var key = FlxKey.toStringMap.get(evt.keyCode);

		var binds:Array<String> = [
			FlxG.save.data.leftBind,
			FlxG.save.data.downBind,
			FlxG.save.data.upBind,
			FlxG.save.data.rightBind
		];

		var data = -1;

		switch (evt.keyCode) // arrow keys
		{
			case 37:
				data = 0;
			case 40:
				data = 1;
			case 38:
				data = 2;
			case 39:
				data = 3;
		}

		for (i in 0...binds.length) // binds
		{
			if (binds[i].toLowerCase() == key.toLowerCase())
				data = i;
		}
		if (data == -1)
		{
			trace("couldn't find a keybind with the code " + key);
			return;
		}
		if (keys[data])
		{
			trace("ur already holding " + key);
			return;
		}

		keys[data] = true;

		var ana = new Ana(Conductor.songPosition, null, false, "miss", data);

		closestNotes = [];

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.wasGoodHit)
				closestNotes.push(daNote);
		}); // Collect notes that can be hit

		closestNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

		var dataNotes = [];
		for (i in closestNotes)
			if (i.noteData == data && !i.isSustainNote)
				dataNotes.push(i);

		trace("notes able to hit for " + key.toString() + " " + dataNotes.length);

		if (dataNotes.length != 0)
		{
			var coolNote = null;

			for (i in dataNotes)
			{
				coolNote = i;
				break;
			}

			if (dataNotes.length > 1) // stacked notes or really close ones
			{
				for (i in 0...dataNotes.length)
				{
					if (i == 0) // skip the first note
						continue;

					var note = dataNotes[i];

					if (!note.isSustainNote && ((note.strumTime - coolNote.strumTime) < 2) && note.noteData == data)
					{
						trace('found a stacked/really close note ' + (note.strumTime - coolNote.strumTime));
						// just fuckin remove it since it's a stacked note and shouldn't be there
						note.kill();
						notes.remove(note, true);
						note.destroy();
					}
				}
			}

			if (!PlayStateChangeables.opponentMode)
				boyfriend.holdTimer = 0;
			else
				dad.holdTimer = 0;
			goodNoteHit(coolNote);
			var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
			ana.hit = true;
			ana.hitJudge = Ratings.judgeNote(noteDiff);
			ana.nearestNote = [coolNote.strumTime, coolNote.noteData, coolNote.sustainLength];
		}
		else if (!FlxG.save.data.ghost && songStarted)
		{
			noteMiss(data, null);
			ana.hit = false;
			ana.hitJudge = "shit";
			ana.nearestNote = [];
			if (!PlayStateChangeables.opponentMode)
				health -= 0.04 * PlayStateChangeables.healthLoss;
			else
				health += 0.04 * PlayStateChangeables.healthLoss;
		}
	}

	public var songStarted = false;

	public var doAnything = false;

	public var bar:FlxSprite;

	function startSong():Void
	{
		startingSong = false;
		songStarted = true;
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.songId), 1, false);
		// FlxG.sound.music.play();
		vocals.play();

		// have them all dance when the song starts
		if (!FlxG.save.data.optimize)
		{
			if (allowedToHeadbang)
				gf.dance();
			if (idleToBeat && !boyfriend.animation.curAnim.name.startsWith("sing"))
				boyfriend.dance(forcedToIdle);
			if (idleToBeat && !dad.animation.curAnim.name.startsWith("sing") && !PlayStateChangeables.opponentMode)
				dad.dance(forcedToIdle);

			// Song check real quick
			switch (SONG.songId)
			{
				case 'bopeebo' | 'philly' | 'blammed' | 'cocoa' | 'eggnog':
					allowedToCheer = true;
				default:
					allowedToCheer = false;
			}
		}

		if (useVideo)
			GlobalVideo.get().resume();

		#if FEATURE_LUAMODCHART
		if (executeModchart)
			luaModchart.executeState("songStart", [null]);
		#end

		FlxG.sound.music.time = startTime;
		if (vocals != null)
			vocals.time = startTime;
		Conductor.songPosition = startTime;
		startTime = 0;

		// Song duration in a float, useful for the time left feature
		songLength = ((FlxG.sound.music.length / songMultiplier) / 1000);

		songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('healthBar'));
		if (PlayStateChangeables.useDownscroll)
			songPosBG.y = FlxG.height * 0.9 + 35;
		songPosBG.screenCenter(X);
		songPosBG.scrollFactor.set();

		songPosBar = new FlxBar(640 - (Std.int(songPosBG.width - 100) / 2), songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 100),
			Std.int(songPosBG.height + 6), this, 'songPositionBar', 0, songLength);
		songPosBar.alpha = 0;
		songPosBar.scrollFactor.set();
		songPosBar.createGradientBar([FlxColor.BLACK], [boyfriend.barColor, dad.barColor]);
		songPosBar.numDivisions = !FlxG.save.data.optimize ? 800 : 100;
		add(songPosBar);

		bar = new FlxSprite(songPosBar.x, songPosBar.y).makeGraphic(Math.floor(songPosBar.width), Math.floor(songPosBar.height), FlxColor.TRANSPARENT);
		bar.alpha = 0;
		add(bar);

		FlxSpriteUtil.drawRect(bar, 0, 0, songPosBar.width, songPosBar.height, FlxColor.TRANSPARENT,
			{thickness: 4, color: (FlxG.save.data.optimize ? FlxColor.WHITE : FlxColor.BLACK)});

		songPosBG.width = songPosBar.width;

		songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - (SONG.songName.length * 5), songPosBG.y - 15, 0, SONG.songName, 16);
		songName.setFormat(Paths.font("aironec.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		songName.scrollFactor.set();

		songName.text = songFixedName + ' (' + FlxStringUtil.formatTime(songLength, false) + ')';
		songName.y = songPosBG.y + (songPosBG.height / 3) - 2.75;
		songName.alpha = 0;
		songName.visible = FlxG.save.data.songPosition;
		songName.antialiasing = FlxG.save.data.antialiasing;
		add(songName);

		songPosBG.cameras = [camHUD];
		bar.cameras = [camHUD];
		songPosBar.cameras = [camHUD];
		songName.cameras = [camHUD];

		songName.screenCenter(X);

		songName.visible = FlxG.save.data.songPosition;
		songPosBar.visible = FlxG.save.data.songPosition;
		bar.visible = FlxG.save.data.songPosition;

		if (FlxG.save.data.songPosition)
		{
			FlxTween.tween(songName, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
			FlxTween.tween(songPosBar, {alpha: 0.85}, 0.5, {ease: FlxEase.circOut});
			FlxTween.tween(bar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		}

		/*@:privateAccess
			{
				var aux = AL.createAux();
				var fx = AL.createEffect();
				AL.effectf(fx,AL.PITCH,songMultiplier);
				AL.auxi(aux, AL.EFFECTSLOT_EFFECT, fx);
				var instSource = FlxG.sound.music._channel.__source;

				var backend:lime._internal.backend.native.NativeAudioSource = instSource.__backend;

				AL.source3i(backend.handle, AL.AUXILIARY_SEND_FILTER, aux, 1, AL.FILTER_NULL);
				if (vocals != null)
				{
					var vocalSource = vocals._channel.__source;

					backend = vocalSource.__backend;
					AL.source3i(backend.handle, AL.AUXILIARY_SEND_FILTER, aux, 1, AL.FILTER_NULL);
				}

				trace("pitched to " + songMultiplier);
		}*/

		#if cpp
		@:privateAccess
		{
			lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
			if (vocals.playing)
				lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
		}
		trace("pitched inst and vocals to " + songMultiplier);
		#end

		if (needSkip)
		{
			skipActive = true;
			skipText = new FlxText(healthBarBG.x + 80, 500, 500);
			skipText.text = "Press Space to Skip Intro";
			skipText.size = 30;
			skipText.color = FlxColor.WHITE;
			skipText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2, 1);
			skipText.cameras = [camHUD];
			skipText.alpha = 0;
			FlxTween.tween(skipText, {alpha: 1}, 0.2);
			add(skipText);
		}
	}

	var debugNum:Int = 0;

	public function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.songId;

		/*if (SONG.songId == 'i') // Forced to do this due a bug that makes all stage events happen on song start BRUH
			{
				add(Stage.swagBacks['bg']);
				Stage.swagBacks['bg2'].visible = false;
				if (FlxG.save.data.distractions)
				{
					Stage.swagBacks['stageFront'].visible = false;
					Stage.swagBacks['hotGirlBG'].visible = false;
					Stage.swagBacks['coolCatBG'].visible = false;
				}
		}*/

		#if FEATURE_STEPMANIA
		if (SONG.needsVoices && !isSM)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.songId));
		else
			vocals = new FlxSound();
		#else
		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.songId));
		else
			vocals = new FlxSound();
		#end

		FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.songId)));

		trace('loaded vocals');

		FlxG.sound.list.add(vocals);

		if (!paused)
		{
			#if FEATURE_STEPMANIA
			if (!isStoryMode && isSM)
			{
				trace("Loading " + pathToSm + "/" + sm.header.MUSIC);
				var bytes = File.getBytes(pathToSm + "/" + sm.header.MUSIC);
				var sound = new Sound();
				sound.loadCompressedDataFromByteArray(bytes.getData(), bytes.length);
				FlxG.sound.playMusic(sound);
			}
			/*else
					FlxG.sound.playMusic(Paths.inst(PlayState.SONG.songId), 1, false);
				#else
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.songId), 1, false); */
			#end
		}

		FlxG.sound.music.pause();

		Conductor.crochet = ((60 / (SONG.bpm) * 1000));
		Conductor.stepCrochet = Conductor.crochet / 4;

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = (songNotes[0] - FlxG.save.data.offset - songOffset) / songMultiplier;
				if (daStrumTime < 0)
					daStrumTime = 0;
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3 && !PlayStateChangeables.opponentMode)
					gottaHitNote = !section.mustHitSection;
				else if (songNotes[1] <= 3 && PlayStateChangeables.opponentMode)
					gottaHitNote = !section.mustHitSection;

				var oldNote:Note;

				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;
				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, false, false, songNotes[4]);

				if ((!gottaHitNote && FlxG.save.data.middleScroll && FlxG.save.data.optimize && !PlayStateChangeables.opponentMode)
					|| (!gottaHitNote && FlxG.save.data.middleScroll && FlxG.save.data.optimize && PlayStateChangeables.opponentMode))
					continue;

				if (PlayStateChangeables.holds)
				{
					swagNote.sustainLength = songNotes[2] / songMultiplier;
				}
				else
				{
					swagNote.sustainLength = 0;
				}

				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;

				unspawnNotes.push(swagNote);

				swagNote.isAlt = songNotes[3]

					|| ((section.altAnim || section.CPUAltAnim) && !gottaHitNote)
					|| (section.playerAltAnim && gottaHitNote)
					|| (PlayStateChangeables.opponentMode && gottaHitNote && (section.altAnim || section.CPUAltAnim))
					|| (PlayStateChangeables.opponentMode && !gottaHitNote && section.playerAltAnim);

				if (susLength > 0)
					swagNote.isParent = true;

				var type = 0;
				var floorSus:Int = Math.floor(susLength);
				if (floorSus > 0)
				{
					for (susNote in 0...floorSus + 1)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
						sustainNote.scrollFactor.set();
						unspawnNotes.push(sustainNote);
						sustainNote.isAlt = songNotes[3]
							|| ((section.altAnim || section.CPUAltAnim) && !gottaHitNote)
							|| (section.playerAltAnim && gottaHitNote)
							|| (PlayStateChangeables.opponentMode && gottaHitNote && (section.altAnim || section.CPUAltAnim))
							|| (PlayStateChangeables.opponentMode && !gottaHitNote && section.playerAltAnim);

						sustainNote.mustPress = gottaHitNote;

						if (sustainNote.mustPress)
						{
							sustainNote.x += FlxG.width / 2; // general offset
						}

						sustainNote.parent = swagNote;
						swagNote.children.push(sustainNote);
						sustainNote.spotInLine = type;
						type++;
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;

		Debug.logTrace("whats the fuckin shit");
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function removeStaticArrows(?destroy:Bool = false)
	{
		playerStrums.forEach(function(babyArrow:StaticArrow)
		{
			playerStrums.remove(babyArrow);
			if (destroy)
				babyArrow.destroy();
		});
		cpuStrums.forEach(function(babyArrow:StaticArrow)
		{
			cpuStrums.remove(babyArrow);
			if (destroy)
				babyArrow.destroy();
		});
		strumLineNotes.forEach(function(babyArrow:StaticArrow)
		{
			strumLineNotes.remove(babyArrow);
			if (destroy)
				babyArrow.destroy();
		});
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:StaticArrow = new StaticArrow(-10, strumLine.y);

			// defaults if no noteStyle was found in chart
			var noteTypeCheck:String = 'normal';

			/*if (FlxG.save.data.optimize && player == 0)
				continue; */

			if (SONG.noteStyle == null && FlxG.save.data.overrideNoteskins)
			{
				switch (storyWeek)
				{
					case 6:
						noteTypeCheck = 'pixel';
				}
			}
			else
			{
				noteTypeCheck = SONG.noteStyle;
			}

			switch (noteTypeCheck)
			{
				case 'pixel':
					babyArrow.loadGraphic(noteskinPixelSprite, true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * CoolUtil.daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					babyArrow.x += Note.swagWidth * i;
					babyArrow.animation.add('static', [i]);
					babyArrow.animation.add('pressed', [4 + i, 8 + i], 12, false);
					babyArrow.animation.add('confirm', [12 + i, 16 + i], 24, false);

					for (j in 0...4)
					{
						babyArrow.animation.add('dirCon' + j, [12 + j, 16 + j], 24, false);
					}

				default:
					babyArrow.frames = noteskinSprite;
					Debug.logTrace(babyArrow.frames);
					for (j in 0...4)
					{
						babyArrow.animation.addByPrefix(dataColor[j], 'arrow' + dataSuffix[j]);
						babyArrow.animation.addByPrefix('dirCon' + j, dataSuffix[j].toLowerCase() + ' confirm', 24, false);
					}

					var lowerDir:String = dataSuffix[i].toLowerCase();

					babyArrow.animation.addByPrefix('static', 'arrow' + dataSuffix[i]);
					babyArrow.animation.addByPrefix('pressed', lowerDir + ' press', 24, false);
					babyArrow.animation.addByPrefix('confirm', lowerDir + ' confirm', 24, false);

					babyArrow.x += Note.swagWidth * i;

					babyArrow.antialiasing = FlxG.save.data.antialiasing;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (storyPlaylist.length < 3) // Change to 4 if your week has more than 3 songs.
				babyArrow.alpha = 1;
			if (!isStoryMode || storyPlaylist.length >= 3 || SONG.songId == 'tutorial') // For default each week has 3 songs. So only in the first song will do the tween, in the others the strums already appeared.
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			switch (player)
			{
				case 0:
					if (!PlayStateChangeables.opponentMode)
					{
						babyArrow.x += 20;
						cpuStrums.add(babyArrow);
					}
					else
					{
						playerStrums.add(babyArrow);
					}
				case 1:
					if (!PlayStateChangeables.opponentMode)
						playerStrums.add(babyArrow);
					else
					{
						babyArrow.x += 20;
						cpuStrums.add(babyArrow);
					}
			}

			babyArrow.playAnim('static');
			babyArrow.x += 98.5;
			babyArrow.x += ((FlxG.width / 2) * player);

			if (FlxG.save.data.middleScroll && !executeModchart)
			{
				if (!PlayStateChangeables.opponentMode)
					babyArrow.x -= 308.5;
				else
					babyArrow.x += 332.5;
			}

			cpuStrums.forEach(function(spr:FlxSprite)
			{
				spr.centerOffsets(); // CPU arrows start out slightly off-center
			});

			strumLineNotes.add(babyArrow);
		}
	}

	/*private function appearStaticArrows():Void
		{
			var index = 0;
			strumLineNotes.forEach(function(babyArrow:FlxSprite)
			{
				if (isStoryMode && !FlxG.save.data.middleScroll || executeModchart)
					babyArrow.alpha = 1;
				if (index > 3 && FlxG.save.data.middleScroll && isStoryMode)
				{
					babyArrow.alpha = 1;
					index++;
				}
				else if (index > 3)
			});
	}*/
	function tweenCamIn():Void
	{
		FlxTween.tween(camGame, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music.playing)
			{
				FlxG.sound.music.pause();
				if (vocals != null)
					if (vocals.playing)
						vocals.pause();
			}
			#if FEATURE_LUAMODCHART
			if (LuaReceptor.receptorTween != null)
				LuaReceptor.receptorTween.active = false;
			#end

			if (scrollTween != null)
				scrollTween.active = false;

			if (Stage.rasisTween != null)
				Stage.rasisTween.active = false;

			if (Stage.spinCat != null)
				Stage.spinCat.active = false;

			#if FEATURE_DISCORD
			if (!endingSong)
			{
				if (FlxG.save.data.discordMode != 0)
					DiscordClient.changePresence("PAUSED on " + "\n" + songFixedName + " (" + storyDifficultyText + " " + songMultiplier + "x" + ") "
						+ Ratings.GenerateComboRank(accuracy) + " " + Ratings.GenerateLetterRank(accuracy),
						"\nScr: " + songScore + " ("
						+ HelperFunctions.truncateFloat(accuracy, 2) + "%)" + " | Misses: " + misses, iconRPC);
				else
					DiscordClient.changePresence("PAUSED on " + songFixedName + " (" + storyDifficultyText + " " + songMultiplier + "x" + ") ", "", iconRPC);
			}
			#end
			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (PauseSubState.goToOptions)
		{
			Debug.logTrace("pause thingyt");
			if (PauseSubState.goBack)
			{
				Debug.logTrace("pause thingyt");
				PauseSubState.goToOptions = false;
				PauseSubState.goBack = false;
				openSubState(new PauseSubState());
			}
			else
				openSubState(new OptionsMenu(true));
		}
		else if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}
			#if FEAUTURE_LUAMODCHART
			if (LuaReceptor.receptorTween != null)
				LuaReceptor.receptorTween.active = true;
			#end
			if (scrollTween != null)
				scrollTween.active = true;

			if (Stage.rasisTween != null)
				Stage.rasisTween.active = true;

			if (Stage.spinCat != null)
				Stage.spinCat.active = true;
			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if FEATURE_DISCORD
			if (FlxG.save.data.discordMode != 0)
			{
				DiscordClient.changePresence(songFixedName + " (" + storyDifficultyText + " " + songMultiplier + "x" + ") "
					+ Ratings.GenerateComboRank(accuracy) + " " + Ratings.GenerateLetterRank(accuracy),
					"\nScr: " + songScore + " ("
					+ HelperFunctions.truncateFloat(accuracy, 2) + "%)" + " | Misses: " + misses, iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	function resyncVocals():Void
	{
		if (endingSong)
			return;
		vocals.pause();
		FlxG.sound.music.pause();

		FlxG.sound.music.play();
		FlxG.sound.music.time = Conductor.songPosition * songMultiplier;
		vocals.time = FlxG.sound.music.time;
		vocals.play();

		@:privateAccess
		{
			#if desktop
			// The __backend.handle attribute is only available on native.
			lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
			if (vocals.playing)
				lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
			#end
		}
	}

	function percentageOfSong():Float
	{
		return (Conductor.songPosition / songLength) * 100;
	}

	public var paused:Bool = false;

	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var nps:Int = 0;
	var maxNPS:Int = 0;

	public var stopUpdate = false;
	public var removedVideo = false;

	public var currentBPM = 0;

	public var updateFrame = 0;

	public var pastScrollChanges:Array<Song.Event> = [];

	var currentLuaIndex = 0;

	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end
		shownSongScore = Math.floor(FlxMath.lerp(shownSongScore, songScore, CoolUtil.boundTo(Main.adjustFPS(0.1), 0, 1)));
		shownAccuracy = FlxMath.lerp(shownAccuracy, accuracy, CoolUtil.boundTo(Main.adjustFPS(0.1), 0, 1));

		if (Math.abs(shownAccuracy - accuracy) <= 0)
			shownAccuracy = accuracy;

		if (Math.abs(shownSongScore - songScore) <= 100)
			shownSongScore = songScore;

		if (FlxG.save.data.lerpScore)
			scoreTxt.text = Ratings.CalculateRanking(shownSongScore, songScoreDef, nps, maxNPS,
				(FlxG.save.data.roundAccuracy ? FlxMath.roundDecimal(shownAccuracy, 0) : shownAccuracy));

		if (generatedMusic && !paused && songStarted && songMultiplier < 1)
		{
			if (Conductor.songPosition * songMultiplier > FlxG.sound.music.time + 25
				|| Conductor.songPosition * songMultiplier < FlxG.sound.music.time - 25)
			{
				resyncVocals();
			}
		}

		#if FEATURE_DISCORD
		if (FlxG.save.data.discordMode == 2)
		{
			DiscordClient.changePresence(songFixedName + " (" + storyDifficultyText + " " + songMultiplier + "x" + ") "
				+ Ratings.GenerateComboRank(accuracy) + " " + Ratings.GenerateLetterRank(accuracy),
				"\nScr: " + songScore + " ("
				+ HelperFunctions.truncateFloat(accuracy, 2) + "%)" + " | Misses: " + misses, iconRPC);
		}
		#end

		if (health <= 0 && PlayStateChangeables.practiceMode)
			health = 0;
		else if (health >= 2 && PlayStateChangeables.practiceMode)
			health = 2;

		if (!FlxG.save.data.optimize)
			Stage.update(elapsed);

		if (!addedBotplay && FlxG.save.data.botplay && !isStoryMode)
		{
			PlayStateChangeables.botPlay = true;
			addedBotplay = true;
			add(botPlayState);
		}

		if (unspawnNotes[0] != null)
		{
			var shit:Float = 14000;
			if (SONG.speed < 1 || scrollSpeed < 1)
				shit /= scrollSpeed == 1 ? SONG.speed : scrollSpeed;
			if (unspawnNotes[0].strumTime - Conductor.songPosition < shit)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);
				#if FEATURE_LUAMODCHART
				if (executeModchart)
				{
					currentLuaIndex++;
					var n = new LuaNote(dunceNote, currentLuaIndex);
					n.Register(ModchartState.lua);
					ModchartState.shownNotes.push(n);
					dunceNote.LuaNote = n;
					dunceNote.luaID = currentLuaIndex;
				}
				#end

				if (executeModchart)
				{
					#if FEATURE_LUAMODCHART
					if (!dunceNote.isSustainNote)
						dunceNote.cameras = [camNotes];
					else
						dunceNote.cameras = [camSustains];
					#end
				}
				else
				{
					dunceNote.cameras = [camHUD];
				}

				unspawnNotes.remove(dunceNote);
				currentLuaIndex++;
			}
		}

		#if cpp
		if (FlxG.sound.music.playing)
			@:privateAccess
		{
			lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
			if (vocals.playing)
				lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
		}
		#end

		if (generatedMusic)
		{
			if (songStarted && !endingSong)
			{
				// Song ends abruptly on slow rate even with second condition being deleted,
				// and if it's deleted on songs like cocoa then it would end without finishing instrumental fully,
				// so no reason to delete it at all
				if ((FlxG.sound.music.length / songMultiplier) - Conductor.songPosition <= 0) // WELL THAT WAS EASY
				{
					Debug.logTrace("we're fuckin ending the song ");
					if (FlxG.save.data.songPosition)
					{
						FlxTween.tween(scoreTxt, {alpha: 0}, 1, {ease: FlxEase.circIn});
						FlxTween.tween(songName, {alpha: 0}, 1, {ease: FlxEase.circIn});
						FlxTween.tween(songPosBar, {alpha: 0}, 1, {ease: FlxEase.circIn});
						FlxTween.tween(judgementCounter, {alpha: 0}, 1, {ease: FlxEase.circIn});
						FlxTween.tween(kadeEngineWatermark, {alpha: 0}, 1, {ease: FlxEase.circIn});
						FlxTween.tween(accText, {alpha: 0}, 1, {ease: FlxEase.circIn});
						FlxTween.tween(bar, {alpha: 0}, 1, {
							ease: FlxEase.circIn,
							onComplete: function(twn:FlxTween)
							{
								remove(songName);
								remove(songPosBar);
								remove(bar);
								remove(scoreTxt);
								remove(judgementCounter);
								songName.kill();
								songPosBar.kill();
								bar.kill();
								scoreTxt.kill();
								judgementCounter.kill();
								songName.destroy();
								songPosBar.destroy();
								bar.destroy();
								scoreTxt.destroy();
								judgementCounter.destroy();
							}
						});
					}
					endingSong = true;
					endSong();
				}
			}
		}

		if (updateFrame == 4)
		{
			TimingStruct.clearTimings();

			var currentIndex = 0;
			for (i in SONG.eventObjects)
			{
				if (i.type == "BPM Change")
				{
					var beat:Float = i.position;

					var endBeat:Float = Math.POSITIVE_INFINITY;

					var bpm = i.value * songMultiplier;

					TimingStruct.addTiming(beat, bpm, endBeat, 0); // offset in this case = start time since we don't have a offset

					if (currentIndex != 0)
					{
						var data = TimingStruct.AllTimings[currentIndex - 1];
						data.endBeat = beat;
						data.length = ((data.endBeat - data.startBeat) / (data.bpm / 60)) / songMultiplier;
						var step = ((60 / data.bpm) * 1000) / 4;
						TimingStruct.AllTimings[currentIndex].startStep = Math.floor((((data.endBeat / (data.bpm / 60)) * 1000) / step) / songMultiplier);
						TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length / songMultiplier;
					}

					currentIndex++;
				}
			}

			updateFrame++;
		}
		else if (updateFrame != 5)
			updateFrame++;

		if (FlxG.sound.music.playing)
		{
			var timingSeg = TimingStruct.getTimingAtBeat(curDecimalBeat);

			if (timingSeg != null)
			{
				var timingSegBpm = timingSeg.bpm;

				if (timingSegBpm != Conductor.bpm)
				{
					trace("BPM CHANGE to " + timingSegBpm);
					Conductor.changeBPM(timingSegBpm, false);
					Conductor.crochet = ((60 / (timingSegBpm) * 1000)) / songMultiplier;
					Conductor.stepCrochet = Conductor.crochet / 4;
				}
			}

			var newScroll = 1.0;

			for (i in SONG.eventObjects)
			{
				switch (i.type)
				{
					case "Scroll Speed Change":
						if (i.position <= curDecimalBeat && !pastScrollChanges.contains(i))
						{
							pastScrollChanges.push(i);
							trace("SCROLL SPEED CHANGE to " + i.value);
							newScroll = i.value;
						}
				}
			}

			if (newScroll != 0)
				scrollSpeed *= newScroll;
		}

		if (PlayStateChangeables.botPlay && FlxG.keys.justPressed.ONE)
			camHUD.visible = !camHUD.visible;

		if (useVideo && GlobalVideo.get() != null && !stopUpdate)
		{
			if (GlobalVideo.get().ended && !removedVideo)
			{
				remove(videoSprite);
				removedVideo = true;
			}
		}

		#if FEATURE_LUAMODCHART
		if (executeModchart && luaModchart != null && songStarted)
		{
			luaModchart.setVar('zoomAllowed', FlxG.save.data.camzoom);
			luaModchart.setVar('songPos', Conductor.songPosition);
			luaModchart.setVar('hudZoom', camHUD.zoom);
			luaModchart.setVar('curBeat', HelperFunctions.truncateFloat(curDecimalBeat, 3));
			luaModchart.setVar('cameraZoom', FlxG.camera.zoom);

			luaModchart.executeState('update', [elapsed]);

			for (key => value in luaModchart.luaWiggles)
			{
				trace('wiggle le gaming');
				value.update(elapsed);
			}

			PlayStateChangeables.useDownscroll = luaModchart.getVar("downscroll", "bool");

			/*for (i in 0...strumLineNotes.length) {
				var member = strumLineNotes.members[i];
				member.x = luaModchart.getVar("strum" + i + "X", "float");
				member.y = luaModchart.getVar("strum" + i + "Y", "float");
				member.angle = luaModchart.getVar("strum" + i + "Angle", "float");
			}*/

			FlxG.camera.angle = luaModchart.getVar('cameraAngle', 'float');
			camHUD.angle = luaModchart.getVar('camHudAngle', 'float');

			if (luaModchart.getVar("showOnlyStrums", 'bool'))
			{
				healthBarBG.visible = false;
				kadeEngineWatermark.visible = false;
				healthBar.visible = false;
				iconP1.visible = false;
				iconP2.visible = false;
				scoreTxt.visible = false;
			}
			else
			{
				healthBarBG.visible = true;
				kadeEngineWatermark.visible = true;
				healthBar.visible = true;
				iconP1.visible = true;
				iconP2.visible = true;
				scoreTxt.visible = updatedAcc;
			}

			var p1 = luaModchart.getVar("strumLine1Visible", 'bool');
			var p2 = luaModchart.getVar("strumLine2Visible", 'bool');

			for (i in 0...4)
			{
				strumLineNotes.members[i].visible = p1;
				if (i <= playerStrums.length)
					playerStrums.members[i].visible = p2;
			}

			camNotes.zoom = camHUD.zoom;
			camNotes.x = camHUD.x;
			camNotes.y = camHUD.y;
			camNotes.angle = camHUD.angle;
			camSustains.zoom = camHUD.zoom;
			camSustains.x = camHUD.x;
			camSustains.y = camHUD.y;
			camSustains.angle = camHUD.angle;
		}
		#end

		// reverse iterate to remove oldest notes first and not invalidate the iteration
		// stop iteration as soon as a note is not removed
		// all notes should be kept in the correct order and this is optimal, safe to do every frame/update

		var balls = notesHitArray.length - 1;
		while (balls >= 0)
		{
			var cock:Date = notesHitArray[balls];
			if (cock != null && cock.getTime() + 1000 < Date.now().getTime())
				notesHitArray.remove(cock);
			else
				balls = 0;
			balls--;
		}
		nps = notesHitArray.length;
		if (nps > maxNPS)
			maxNPS = nps;

		if (FlxG.keys.justPressed.NINE)
			iconP1.swapOldIcon();

		scoreTxt.screenCenter(X);

		var pauseBind = FlxKey.fromString(FlxG.save.data.pauseBind);
		var gppauseBind = FlxKey.fromString(FlxG.save.data.gppauseBind);

		if ((FlxG.keys.anyJustPressed([pauseBind]) || KeyBinds.gamepad && FlxG.keys.anyJustPressed([gppauseBind]))
			&& startedCountdown
			&& canPause
			&& !cannotDie)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				trace('GITAROO MAN EASTER EGG');
				MusicBeatState.switchState(new GitarooPause());
				clean();
			}
			else
				openSubState(new PauseSubState());
		}

		if (FlxG.keys.justPressed.FIVE && songStarted)
		{
			songMultiplier = 1;
			if (useVideo)
			{
				GlobalVideo.get().stop();
				remove(videoSprite);
				removedVideo = true;
			}
			cannotDie = true;

			MusicBeatState.switchState(new WaveformTestState());
			clean();
			PlayState.stageTesting = false;
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		if (FlxG.keys.justPressed.SEVEN && !isStoryMode)
		{
			PlayStateChangeables.mirrorMode = false;
			executeModchart = false;
			songMultiplier = 1;
			if (useVideo)
			{
				GlobalVideo.get().stop();
				remove(videoSprite);
				removedVideo = true;
			}
			cannotDie = true;
			PsychTransition.nextCamera = mainCam;
			MusicBeatState.switchState(new ChartingState());
			clean();
			PlayState.stageTesting = false;
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		var iconLerp = CoolUtil.boundTo(1 - (elapsed * 35 * songMultiplier), 0, 1);
		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, iconLerp)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, iconLerp)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		if (health >= 2 && !PlayStateChangeables.opponentMode)
			health = 2;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		/* if (FlxG.keys.justPressed.NINE)
			MusicBeatState.switchState(new Charting()); */

		#if debug
		if (FlxG.keys.justPressed.SIX)
		{
			if (useVideo)
			{
				GlobalVideo.get().stop();
				remove(videoSprite);
				removedVideo = true;
			}

			MusicBeatState.switchState(new AnimationDebug(dad.curCharacter));
			clean();
			PlayState.stageTesting = false;
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		if (!FlxG.save.data.optimize)
			if (FlxG.keys.justPressed.EIGHT && songStarted)
			{
				paused = true;
				if (useVideo)
				{
					GlobalVideo.get().stop();
					remove(videoSprite);
					removedVideo = true;
				}
				new FlxTimer().start(0.3, function(tmr:FlxTimer)
				{
					for (bg in Stage.toAdd)
					{
						remove(bg);
					}
					for (array in Stage.layInFront)
					{
						for (bg in array)
							remove(bg);
					}
					for (group in Stage.swagGroup)
					{
						remove(group);
					}
					remove(boyfriend);
					remove(dad);
					remove(gf);
				});
				MusicBeatState.switchState(new StageDebugState(Stage.curStage, gf.curCharacter, boyfriend.curCharacter, dad.curCharacter));
				clean();
				FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
				FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
				#if FEATURE_LUAMODCHART
				if (luaModchart != null)
				{
					luaModchart.die();
					luaModchart = null;
				}
				#end
			}

		if (FlxG.keys.justPressed.ZERO)
		{
			MusicBeatState.switchState(new AnimationDebug(boyfriend.curCharacter));
			clean();
			PlayState.stageTesting = false;
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		if (FlxG.keys.justPressed.TWO && songStarted)
		{ // Go 10 seconds into the future, credit: Shadow Mario#9396
			if (!usedTimeTravel && Conductor.songPosition + 10000 < FlxG.sound.music.length)
			{
				usedTimeTravel = true;
				FlxG.sound.music.pause();
				vocals.pause();
				Conductor.songPosition += 10000;
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.strumTime - 500 < Conductor.songPosition)
					{
						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});

				FlxG.sound.music.time = Conductor.songPosition;
				FlxG.sound.music.play();

				vocals.time = Conductor.songPosition;
				vocals.play();
				new FlxTimer().start(0.5, function(tmr:FlxTimer)
				{
					usedTimeTravel = false;
				});
			}
		}
		#end

		if (skipActive && Conductor.songPosition >= skipTo)
		{
			FlxTween.tween(skipText, {alpha: 0}, 0.2, {
				onComplete: function(tw)
				{
					remove(skipText);
				}
			});
			skipActive = false;
		}

		if (FlxG.keys.justPressed.SPACE && skipActive)
		{
			FlxG.sound.music.pause();
			vocals.pause();
			Conductor.songPosition = skipTo;
			Conductor.rawPosition = skipTo;

			FlxG.sound.music.time = Conductor.songPosition;
			FlxG.sound.music.play();

			vocals.time = Conductor.songPosition;
			vocals.play();
			FlxTween.tween(skipText, {alpha: 0}, 0.2, {
				onComplete: function(tw)
				{
					remove(skipText);
				}
			});
			skipActive = false;
		}

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				Conductor.rawPosition = Conductor.songPosition;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;
			Conductor.rawPosition = FlxG.sound.music.time;

			// sync

			/*@:privateAccess
				{
					FlxG.sound.music._channel.
			}*/
			songPositionBar = (Conductor.songPosition - songLength) / 1000;

			currentSection = getSectionByTime(Conductor.songPosition);

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}

				var curTime:Float = FlxG.sound.music.time / songMultiplier;
				if (curTime < 0)
					curTime = 0;

				var secondsTotal:Int = Math.floor(((curTime - songLength) / 1000));
				if (secondsTotal < 0)
					secondsTotal = 0;

				songName.text = songFixedName + ' (' + FlxStringUtil.formatTime((songLength - secondsTotal), false) + ')';
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && currentSection != null)
		{
			// Make sure Girlfriend cheers only for certain songs
			if (allowedToCheer)
			{
				// Don't animate GF if something else is already animating her (eg. train passing)
				if (gf.animation.curAnim.name == 'danceLeft'
					|| gf.animation.curAnim.name == 'danceRight'
					|| gf.animation.curAnim.name == 'idle')
				{
					// Per song treatment since some songs will only have the 'Hey' at certain times
					switch (SONG.songId)
					{
						case 'philly':
							{
								// General duration of the song
								if (curStep < Math.floor(1000 * songMultiplier))
								{
									// Beats to skip or to stop GF from cheering
									if (curStep != Math.floor(736 * songMultiplier) && curStep != Math.floor(864 * songMultiplier))
									{
										if (curStep % Math.floor(64 * songMultiplier) == Math.floor(32 * songMultiplier))
										{
											// Just a garantee that it'll trigger just once
											if (!triggeredAlready)
											{
												gf.playAnim('cheer');
												triggeredAlready = true;
											}
										}
										else
											triggeredAlready = false;
									}
								}
							}
						case 'bopeebo':
							{
								// Where it starts || where it ends
								if (curStep > Math.floor(20 * songMultiplier) && curStep < Math.floor(520 * songMultiplier))
								{
									if (curStep % Math.floor(32 * songMultiplier) == Math.floor(28 * songMultiplier))
									{
										if (!triggeredAlready)
										{
											gf.playAnim('cheer');
											triggeredAlready = true;
										}
									}
									else
										triggeredAlready = false;
								}
							}
						case 'blammed':
							{
								if (curStep > Math.floor(120 * songMultiplier) && curStep < Math.floor(760 * songMultiplier))
								{
									if (curStep < Math.floor(360 * songMultiplier) || curStep > Math.floor(512 * songMultiplier))
									{
										if (curStep % Math.floor(16 * songMultiplier) == Math.floor(8 * songMultiplier))
										{
											if (!triggeredAlready)
											{
												gf.playAnim('cheer');
												triggeredAlready = true;
											}
										}
										else
											triggeredAlready = false;
									}
								}
							}
						case 'cocoa':
							{
								if (curStep < Math.floor(680 * songMultiplier))
								{
									if (curStep < Math.floor(260 * songMultiplier)
										|| curStep > Math.floor(520 * songMultiplier)
										&& curStep < Math.floor(580 * songMultiplier))
									{
										if (curStep % Math.floor(64 * songMultiplier) == Math.floor(60 * songMultiplier))
										{
											if (!triggeredAlready)
											{
												gf.playAnim('cheer');
												triggeredAlready = true;
											}
										}
										else
											triggeredAlready = false;
									}
								}
							}
						case 'eggnog':
							{
								if (curStep > Math.floor(40 * songMultiplier)
									&& curStep != Math.floor(444 * songMultiplier)
									&& curStep < Math.floor(880 * songMultiplier))
								{
									if (curStep % Math.floor(32 * songMultiplier) == Math.floor(28 * songMultiplier))
									{
										if (!triggeredAlready)
										{
											gf.playAnim('cheer');
											triggeredAlready = true;
										}
									}
									else
										triggeredAlready = false;
								}
							}
					}
				}
			}

			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
				luaModchart.setVar("mustHit", currentSection.mustHitSection);
			#end

			if (!PlayState.SONG.notes[Std.int((curStep / 16) / songMultiplier)].mustHitSection)
			{
				var offsetX = 0;
				var offsetY = 0;
				#if FEATURE_LUAMODCHART
				if (luaModchart != null)
				{
					offsetX = luaModchart.getVar("followXOffset", "float");
					offsetY = luaModchart.getVar("followYOffset", "float");
				}
				#end
				if (Stage.curStage != 'voltexStage')
					camFollow.setPosition(dad.getMidpoint().x + 150 + offsetX, dad.getMidpoint().y - 100 + offsetY);
				else
					camFollow.setPosition(gf.getMidpoint().x, gf.getMidpoint().y);
				#if FEATURE_LUAMODCHART
				if (luaModchart != null)
					luaModchart.executeState('playerTwoTurn', []);
				#end
				// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

				camFollow.x += dad.camFollow[0];
				camFollow.y += dad.camFollow[1];
			}

			if (PlayState.SONG.notes[Std.int((curStep / 16) / songMultiplier)].mustHitSection)
			{
				var offsetX = 0;
				var offsetY = 0;
				#if FEATURE_LUAMODCHART
				if (luaModchart != null)
				{
					offsetX = luaModchart.getVar("followXOffset", "float");
					offsetY = luaModchart.getVar("followYOffset", "float");
				}
				#end
				if (Stage.curStage != 'voltexStage')
					camFollow.setPosition(boyfriend.getMidpoint().x - 100 + offsetX, boyfriend.getMidpoint().y - 100 + offsetY);
				else
					camFollow.setPosition(gf.getMidpoint().x, gf.getMidpoint().y);

				#if FEATURE_LUAMODCHART
				if (luaModchart != null)
					luaModchart.executeState('playerOneTurn', []);
				#end
				if (!FlxG.save.data.optimize)
					switch (Stage.curStage)
					{
						case 'limo':
							camFollow.x = boyfriend.getMidpoint().x - 300;
						case 'mall':
							camFollow.y = boyfriend.getMidpoint().y - 200;
						case 'school' | 'schoolEvil':
							camFollow.x = boyfriend.getMidpoint().x - 300;
							camFollow.y = boyfriend.getMidpoint().y - 300;
					}

				camFollow.x += boyfriend.camFollow[0];
				camFollow.y += boyfriend.camFollow[1];
			}

			if (FlxG.save.data.cameramove)
			{
				camFollow.setPosition(gf.getMidpoint().x, gf.getMidpoint().y);
				camFollow.x += camX;
				camFollow.y += camY;
			}
		}

		if (camZooming)
		{
			if (FlxG.save.data.zoom < 0.8)
				FlxG.save.data.zoom = 0.8;

			if (FlxG.save.data.zoom > 1.2)
				FlxG.save.data.zoom = 1.2;

			var bpmRatio = SONG.bpm / 100;
			if (!executeModchart)
			{
				FlxG.camera.zoom = FlxMath.lerp(Stage.camZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * songMultiplier * bpmRatio), 0, 1));
				camHUD.zoom = FlxMath.lerp(FlxG.save.data.zoom, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * songMultiplier * bpmRatio), 0, 1));

				camNotes.zoom = camHUD.zoom;
				camSustains.zoom = camHUD.zoom;
			}
			else
			{
				FlxG.camera.zoom = FlxMath.lerp(Stage.camZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * songMultiplier * bpmRatio), 0, 1));
				camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * songMultiplier * bpmRatio), 0, 1));

				camNotes.zoom = camHUD.zoom;
				camSustains.zoom = camHUD.zoom;
			}
		}

		FlxG.watch.addQuick("curBPM", Conductor.bpm);
		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = FlxG.save.data.camzoom;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
				case 163:
					// FlxG.sound.music.stop();
					// MusicBeatState.switchState(new TitleState());
			}
		}

		if ((health <= 0 && !cannotDie && !PlayStateChangeables.practiceMode && !PlayStateChangeables.opponentMode)
			|| (health > 2 && !cannotDie && !PlayStateChangeables.practiceMode && PlayStateChangeables.opponentMode))
		{
			if (!usedTimeTravel)
			{
				boyfriend.stunned = true;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				if (FlxG.save.data.InstantRespawn || FlxG.save.data.optimize)
				{
					MusicBeatState.switchState(new PlayState());
				}
				else
				{
					openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				}

				#if FEATURE_DISCORD
				// Game Over doesn't get his own variable because it's only used here
				if (FlxG.save.data.discordMode != 0)
				{
					DiscordClient.changePresence("GAME OVER -- " + "\n" + songFixedName + " (" + storyDifficultyText + " " + songMultiplier + "x" + ") "
						+ Ratings.GenerateComboRank(accuracy) + " " + Ratings.GenerateLetterRank(accuracy),
						"\nScr: " + songScore + " ("
						+ HelperFunctions.truncateFloat(accuracy, 2) + "%)" + " | Misses: " + misses, iconRPC);
				}
				else
				{
					DiscordClient.changePresence("GAME OVER -- " + "\nPlaying " + songFixedName + " (" + storyDifficultyText + " " + songMultiplier + "x"
						+ ") ", "", iconRPC);
				}
				#end
				// God I love watching Yosuga No Sora with my sister (From: Bolo)
				// God i love futabu!! so fucking much (From: McChomk)
				// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			}
			else
				health = 1;
		}
		if (!inCutscene && FlxG.save.data.resetButton)
		{
			var resetBind = FlxKey.fromString(FlxG.save.data.resetBind);
			var gpresetBind = FlxKey.fromString(FlxG.save.data.gpresetBind);
			if ((FlxG.keys.anyJustPressed([resetBind]) || KeyBinds.gamepad && FlxG.keys.anyJustPressed([gpresetBind])))
			{
				boyfriend.stunned = true;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				if (FlxG.save.data.InstantRespawn || FlxG.save.data.optimize)
				{
					MusicBeatState.switchState(new PlayState());
				}
				else
				{
					openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				}

				#if FEATURE_DISCORD
				// Game Over doesn't get his own variable because it's only used here
				if (FlxG.save.data.discordMode != 0)
				{
					DiscordClient.changePresence("GAME OVER -- " + "\n" + songFixedName + " (" + storyDifficultyText + " " + songMultiplier + "x" + ") "
						+ Ratings.GenerateComboRank(accuracy) + " " + Ratings.GenerateLetterRank(accuracy),
						"\nScr: " + songScore + " ("
						+ HelperFunctions.truncateFloat(accuracy, 2) + "%)" + " | Misses: " + misses, iconRPC);
				}
				else
				{
					DiscordClient.changePresence("GAME OVER -- " + "\nPlaying " + songFixedName + " (" + storyDifficultyText + " " + songMultiplier + "x"
						+ ") ", "", iconRPC);
				}
				#end

				// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			}
		}

		if (generatedMusic && !inCutscene)
		{
			var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
			var stepHeight = (0.45 * Conductor.stepCrochet * FlxMath.roundDecimal((PlayState.SONG.speed * PlayState.songMultiplier) * PlayState.songMultiplier,
				2));

			notes.forEachAlive(function(daNote:Note)
			{
				// instead of doing stupid y > FlxG.height
				// we be men and actually calculate the time :)
				var strumY = (daNote.mustPress ? playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y : strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y);
				var origin = strumY + Note.swagWidth / 2;
				if (!daNote.modifiedByLua)
				{
					if (PlayStateChangeables.useDownscroll)
					{
						daNote.y = (strumY
							+
							0.45 * ((Conductor.songPosition - daNote.strumTime) / songMultiplier) * (FlxMath.roundDecimal(scrollSpeed == 1 ? SONG.speed : scrollSpeed,
								2)))
							- (!songStarted && songMultiplier > 1 ? daNote.noteYOff / Math.pow(songMultiplier, 4) : daNote.noteYOff);
						if (daNote.isSustainNote)
						{
							var bpmRatio = (SONG.bpm / 100);

							if ((!daNote.animation.curAnim.name.endsWith('end') && !songStarted) || songStarted)
								daNote.y -= daNote.height - (1.5 * stepHeight / SONG.speed * bpmRatio);
							if (daNote.animation.curAnim.name.endsWith('end') && daNote.prevNote != null && !songStarted)
								daNote.y += (daNote.prevNote.height * bpmRatio) / (scrollSpeed == 1 ? SONG.speed * 1.2 : scrollSpeed * 1.2);

							// Kinda newbie way for fixing hold sustain notes but it works :o (-Bolo)
							// If not in botplay, only clip sustain notes when properly hit, botplay gets to clip it everytime
							if (daNote.sustainActive)
							{
								if ((PlayStateChangeables.botPlay
									|| !daNote.mustPress
									|| daNote.wasGoodHit
									|| (daNote.prevNote.wasGoodHit && !daNote.canBeHit)
									|| holdArray[Math.floor(Math.abs(daNote.noteData))])
									&& daNote.y
									- daNote.offset.y * daNote.scale.y
									+ daNote.height >= origin)
								{
									// Clip to strumline
									var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
									swagRect.height = ((strumY + Note.swagWidth / 2) - daNote.y) / daNote.scale.y;
									swagRect.y = daNote.frameHeight - swagRect.height;

									daNote.clipRect = swagRect;
								}
							}
						}
					}
					else
					{
						daNote.y = (strumY
							- 0.45 * ((Conductor.songPosition - daNote.strumTime) / songMultiplier) * (FlxMath.roundDecimal(scrollSpeed == 1 ? SONG.speed : scrollSpeed,
								2)))
							+ (!songStarted && songMultiplier > 1 ? daNote.noteYOff / Math.pow(songMultiplier, 5) : daNote.noteYOff);
						if (daNote.isSustainNote && daNote.sustainActive)
						{
							if ((PlayStateChangeables.botPlay
								|| !daNote.mustPress
								|| daNote.wasGoodHit
								|| (daNote.prevNote.wasGoodHit && !daNote.canBeHit)
								|| holdArray[Math.floor(Math.abs(daNote.noteData))])
								&& daNote.y
								+ daNote.offset.y * daNote.scale.y <= origin)
							{
								// Clip to strumline
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = ((strumY + Note.swagWidth / 2) - daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;

								daNote.clipRect = swagRect;
							}
						}
					}
				}

				if (!daNote.mustPress && Conductor.songPosition >= daNote.strumTime)
				{
					if (SONG.songId != 'tutorial')
						camZooming = FlxG.save.data.camzoom;

					var altAnim:String = "";
					var curSection:Int = Math.floor((curStep / 16));

					if (daNote.isAlt)
					{
						altAnim = '-alt';
						trace("YOO WTF THIS IS AN ALT NOTE????");
					}

					if (PlayStateChangeables.healthDrain && !daNote.isSustainNote)
					{
						if (!PlayStateChangeables.opponentMode)
						{
							health -= .04 * PlayStateChangeables.healthLoss;
							if (health <= 0.01)
							{
								health = 0.01;
							}
						}
						else
						{
							health += .04 * PlayStateChangeables.healthLoss;
							if (health >= 2)
								health = 2;
						}
					}

					switch (daNote.noteData)
					{
						case 2:
							camY = -20;
							camX = 0;
						case 3:
							camX = 20;
							camY = 0;
						case 1:
							camY = 20;
							camX = 0;
						case 0:
							camX = -20;
							camY = 0;
					}

					// Accessing the animation name directly to play it
					if (!daNote.isParent && daNote.parent != null)
					{
						if (daNote.spotInLine != daNote.parent.children.length - 1)
						{
							var singData:Int = Std.int(Math.abs(daNote.noteData));
							if (!FlxG.save.data.optimize)
							{
								if (PlayStateChangeables.opponentMode && bfAllowedtoAnim)
								{
									boyfriend.playAnim('sing' + dataSuffix[singData] + altAnim, true);
								}
								else if (opponentAllowedtoAnim)
								{
									dad.playAnim('sing' + dataSuffix[singData] + altAnim, true);
								}
							}

							if (FlxG.save.data.cpuStrums)
							{
								cpuStrums.forEach(function(spr:StaticArrow)
								{
									pressArrow(spr, spr.ID, daNote);
									/*
										if (spr.animation.curAnim.name == 'confirm' && SONG.noteStyle != 'pixel')
										{
											spr.centerOffsets();
											spr.offset.x -= 13;
											spr.offset.y -= 13;
										}
										else
											spr.centerOffsets();
									 */
								});
							}

							#if FEATURE_LUAMODCHART
							if (luaModchart != null)
								luaModchart.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition]);
							#end

							if (!PlayStateChangeables.opponentMode)
								dad.holdTimer = 0;
							else
								boyfriend.holdTimer = 0;

							if (SONG.needsVoices)
								vocals.volume = 1;
						}
					}
					else
					{
						var singData:Int = Std.int(Math.abs(daNote.noteData));
						if (!FlxG.save.data.optimize)
						{
							if (PlayStateChangeables.opponentMode && bfAllowedtoAnim)
								boyfriend.playAnim('sing' + dataSuffix[singData] + altAnim, true);
							else if (opponentAllowedtoAnim)
								dad.playAnim('sing' + dataSuffix[singData] + altAnim, true);
						}

						if (FlxG.save.data.cpuStrums)
						{
							cpuStrums.forEach(function(spr:StaticArrow)
							{
								pressArrow(spr, spr.ID, daNote);
								/*
									if (spr.animation.curAnim.name == 'confirm' && SONG.noteStyle != 'pixel')
									{
										spr.centerOffsets();
										spr.offset.x -= 13;
										spr.offset.y -= 13;
									}
									else
										spr.centerOffsets();
								 */
							});
						}

						#if FEATURE_LUAMODCHART
						if (luaModchart != null)
							if (!PlayStateChangeables.opponentMode)
								luaModchart.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition]);
							else
								luaModchart.executeState('playerOneSing', [Math.abs(daNote.noteData), Conductor.songPosition]);
						#end

						if (!PlayStateChangeables.opponentMode)
							dad.holdTimer = 0;
						else
							boyfriend.holdTimer = 0;

						if (SONG.needsVoices)
							vocals.volume = 1;
					}
					daNote.active = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				if ((daNote.mustPress && !daNote.modifiedByLua))
				{
					// daNote.visible = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].visible;
					daNote.x = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x;
					if (!daNote.isSustainNote)
						daNote.modAngle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].modAngle;
					if (daNote.sustainActive)
					{
						if (executeModchart && daNote.isParent)
							daNote.alpha = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					}
					daNote.modAngle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].modAngle;
				}
				else if (!daNote.wasGoodHit && !daNote.modifiedByLua)
				{
					// daNote.visible = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].visible;
					daNote.x = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].x;
					if (!daNote.isSustainNote)
						daNote.modAngle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].modAngle;
					if (daNote.sustainActive)
					{
						if (executeModchart && daNote.isParent)
							daNote.alpha = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					}
					daNote.modAngle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].modAngle;
				}

				if (PlayStateChangeables.opponentMode
					&& !daNote.mustPress
					&& !FlxG.save.data.middleScroll
					|| (PlayStateChangeables.opponentMode && !daNote.mustPress && FlxG.save.data.middleScroll && executeModchart))
				{
					daNote.x = cpuStrums.members[Math.floor(Math.abs(daNote.noteData))].x;
				}

				if (!daNote.mustPress && FlxG.save.data.middleScroll && !executeModchart && !PlayStateChangeables.opponentMode)
					daNote.alpha = 0;
				else if (!daNote.mustPress && FlxG.save.data.middleScroll && !executeModchart && PlayStateChangeables.opponentMode)
					daNote.alpha = 0;

				if (bigDickFutaOMGIloveItMakemeCumPleaseIwantUtoFillMyBellyWithUrStickyStuffPLEASE == 4) // Correct Voltex Circles X-offset
					daNote.x = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].x + 6; // WTF is that Int var my dude???!!!!
				if (daNote.isSustainNote)
				{
					if (daNote.mustPress)
					{
						daNote.x += daNote.width / 2 + 19.5 - (bigDickFutaOMGIloveItMakemeCumPleaseIwantUtoFillMyBellyWithUrStickyStuffPLEASE == 4 ? 6 : 0);
					}
					else
					{
						if (!FlxG.save.data.middleScroll || executeModchart)
							daNote.x = cpuStrums.members[Math.floor(Math.abs(daNote.noteData))].x
								+ 36.5
								- (bigDickFutaOMGIloveItMakemeCumPleaseIwantUtoFillMyBellyWithUrStickyStuffPLEASE == 4 ? 6 : 0);
					}
					if (SONG.noteStyle == 'pixel')
						daNote.x -= 11;
				}

				// trace(daNote.y);
				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));
				if (Conductor.songPosition > ((350 * songMultiplier) / (scrollSpeed == 1 ? SONG.speed : scrollSpeed)) + daNote.strumTime)
				{
					if (daNote.isSustainNote && daNote.wasGoodHit && Conductor.songPosition >= daNote.strumTime)
					{
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
					if ((daNote.mustPress && daNote.tooLate && !PlayStateChangeables.useDownscroll || daNote.mustPress && daNote.tooLate
						&& PlayStateChangeables.useDownscroll)
						&& daNote.mustPress)
					{
						if (daNote.isSustainNote && daNote.wasGoodHit)
						{
							daNote.kill();
							notes.remove(daNote, true);
						}
						else
						{
							if (loadRep && daNote.isSustainNote)
							{
								// im tired and lazy this sucks I know i'm dumb
								if (findByTime(daNote.strumTime) != null)
									totalNotesHit += 1;
								else
								{
									vocals.volume = 0;
									if (daNote.isParent)
									{
										// health -= 0.15; // give a health punishment for failing a LN
										trace("hold fell over at the start");
										for (i in daNote.children)
										{
											i.alpha = 0.3;
											i.sustainActive = false;
										}
										noteMiss(daNote.noteData, daNote);
									}
									else
									{
										// TODO: Rework this to work with HoldArray instead of wasGoodHit for better hold release detection like a regular rythm game.
										if (!daNote.wasGoodHit
											&& daNote.isSustainNote
											&& daNote.sustainActive
											&& daNote.spotInLine != daNote.parent.children.length)
										{
											// health -= 0.15; // give a health punishment for failing a LN
											trace("hold fell over at " + daNote.spotInLine);
											for (i in daNote.parent.children)
											{
												i.alpha = 0.3;
												i.sustainActive = false;
												if (!PlayStateChangeables.opponentMode)
													health -= (0.04 * PlayStateChangeables.healthLoss) / daNote.parent.children.length;
												else
													health += (0.04 * PlayStateChangeables.healthLoss) / daNote.parent.children.length;
											}
											if (daNote.parent.wasGoodHit)
											{
												totalNotesHit -= 0.5;
											}
											noteMiss(daNote.noteData, daNote);
										}
										else if (!daNote.wasGoodHit && !daNote.isSustainNote)
										{
											noteMiss(daNote.noteData, daNote);
											if (!PlayStateChangeables.opponentMode)
												health -= 0.04 * PlayStateChangeables.healthLoss;
											else
												health += 0.04 * PlayStateChangeables.healthLoss;
										}
									}
								}
							}
							else
							{
								vocals.volume = 0;
								if (theFunne && !daNote.isSustainNote)
								{
									if (PlayStateChangeables.botPlay)
									{
										daNote.rating = "bad";
										goodNoteHit(daNote);
									}
									else
									{
										if (!PlayStateChangeables.opponentMode)
											health -= 0.04 * PlayStateChangeables.healthLoss;
										else
											health += 0.04 * PlayStateChangeables.healthLoss;
									}
								}

								if (daNote.isParent && daNote.visible)
								{
									// health -= 0.15; // give a health punishment for failing a LN
									trace("hold fell over at the start");
									for (i in daNote.children)
									{
										i.alpha = 0.3;
										i.sustainActive = false;
									}
									noteMiss(daNote.noteData, daNote);
								}
								else
								{
									// TODO: Rework this to work this HoldArray instead of wasGoodHit for better hold release detection like a regular rythm game.
									if (!daNote.wasGoodHit
										&& daNote.isSustainNote
										&& daNote.sustainActive
										&& daNote.spotInLine != daNote.parent.children.length)
									{
										// health -= 0.05; // give a health punishment for failing a LN
										trace("hold fell over at " + daNote.spotInLine);
										for (i in daNote.parent.children)
										{
											i.alpha = 0.3;
											i.sustainActive = false;
											if (!PlayStateChangeables.opponentMode)
												health -= (0.04 * PlayStateChangeables.healthLoss) / daNote.parent.children.length;
											else
												health += (0.04 * PlayStateChangeables.healthLoss) / daNote.parent.children.length;
										}
										if (daNote.parent.wasGoodHit)
										{
											totalNotesHit -= 0.5;
										}
										noteMiss(daNote.noteData, daNote);
									}
									else if (!daNote.wasGoodHit && !daNote.isSustainNote)
									{
										noteMiss(daNote.noteData, daNote);
										// health -= 0.1; I forgot replay is broken. So it's not necessary to uncommment deez.
									}
								}
							}
						}

						daNote.visible = false;
						daNote.active = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
					// Epic holdArray fail

					/*if (!holdArray[Math.floor(Math.abs(daNote.noteData))])
						{
							if (daNote.isSustainNote && daNote.sustainActive && daNote.spotInLine != daNote.parent.children.length)
							{
								// health -= 0.05; // give a health punishment for failing a LN
								for (i in daNote.parent.children)
								{
									i.alpha = 0.3;
									i.sustainActive = false;
									if (!PlayStateChangeables.opponentMode)
										health -= (0.04 * PlayStateChangeables.healthLoss) / daNote.parent.children.length;
									else
										health += (0.04 * PlayStateChangeables.healthLoss) / daNote.parent.children.length;
								}
								if (daNote.parent.wasGoodHit)
								{
									totalNotesHit -= 0.5;
								}
								noteMiss(daNote.noteData, daNote);
							}
					}*/
				}
			});
		}

		if (FlxG.save.data.cpuStrums)
		{
			cpuStrums.forEach(function(spr:StaticArrow)
			{
				if (spr.animation.finished)
				{
					spr.playAnim('static');
					spr.centerOffsets();
				}
			});
		}

		if (!inCutscene && songStarted)
			keyShit();

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end

		super.update(elapsed);
	}

	public function getSectionByTime(ms:Float):SwagSection
	{
		for (i in SONG.notes)
		{
			var start = TimingStruct.getTimeFromBeat((TimingStruct.getBeatFromTime(i.startTime)));
			var end = TimingStruct.getTimeFromBeat((TimingStruct.getBeatFromTime(i.endTime)));

			if (ms >= start && ms < end)
			{
				return i;
			}
		}

		return null;
	}

	function recalculateAllSectionTimes()
	{
		trace("RECALCULATING SECTION TIMES");

		for (i in 0...SONG.notes.length) // loops through sections
		{
			var section = SONG.notes[i];

			var currentBeat = 4 * i;

			var currentSeg = TimingStruct.getTimingAtBeat(currentBeat);

			if (currentSeg == null)
				return;

			var start:Float = (currentBeat - currentSeg.startBeat) / ((currentSeg.bpm) / 60);

			section.startTime = (currentSeg.startTime + start) * 1000;

			if (i != 0)
				SONG.notes[i - 1].endTime = section.startTime;
			section.endTime = Math.POSITIVE_INFINITY;
		}
	}

	var openedDialogue:Bool = false;

	function endSong():Void
	{
		endingSong = true;
		camZooming = false;
		bfAllowedtoAnim = false;
		opponentAllowedtoAnim = false;
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
		if (useVideo)
		{
			GlobalVideo.get().stop();
			PlayState.instance.remove(PlayState.instance.videoSprite);
		}

		if (!loadRep)
			rep.SaveReplay(saveNotes, saveJudge, replayAna);
		else
		{
			PlayStateChangeables.botPlay = false;
			scrollSpeed = 1 / songMultiplier;
			PlayStateChangeables.useDownscroll = false;
		}

		if (FlxG.save.data.fpsCap > 300)
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(300);

		#if FEATURE_LUAMODCHART
		if (luaModchart != null)
		{
			luaModchart.die();
			luaModchart = null;
		}
		#end

		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		FlxG.sound.music.stop();
		vocals.stop();

		if (SONG.songId == 'fin4le') // To save scores to dummy novice and advanced difficulties instead of real ones.
		{
			if (storyDifficulty == 4)
			{
				storyDifficulty = 0;
			}
		}

		if (SONG.validScore && (!PlayStateChangeables.botPlay || !addedBotplay) && !FlxG.save.data.practice)
		{
			#if !switch
			Highscore.saveScore(PlayState.SONG.songId, Math.round(songScore), storyDifficulty);
			Highscore.saveCombo(PlayState.SONG.songId, Ratings.GenerateComboRank(accuracy), storyDifficulty);
			Highscore.saveAcc(PlayState.SONG.songId, HelperFunctions.truncateFloat(accuracy, 2), storyDifficulty);
			Highscore.saveLetter(PlayState.SONG.songId, Ratings.GenerateLetterRank(accuracy), storyDifficulty);
			#end
		}

		if (offsetTesting)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			offsetTesting = false;
			LoadingState.loadAndSwitchState(new OptionsMenu());
			clean();
			FlxG.save.data.offset = offsetTest;
		}
		else if (stageTesting)
		{
			new FlxTimer().start(0.3, function(tmr:FlxTimer)
			{
				for (bg in Stage.toAdd)
				{
					remove(bg);
				}
				for (array in Stage.layInFront)
				{
					for (bg in array)
						remove(bg);
				}
				remove(boyfriend);
				remove(dad);
				remove(gf);
			});
			MusicBeatState.switchState(new StageDebugState(Stage.curStage));
		}
		else
		{
			if (isStoryMode && SONG.songId == 'i' && !openedDialogue)
			{
				openedDialogue = true;
				canPause = false;
				Debug.logTrace("Loading hot girl reward dialogue.");
				if (PlayState.storyDifficulty >= 2)
				{
					dialogue = CoolUtil.coolTextFile(Paths.txt('data/songs/${PlayState.SONG.songId}/dialogue_end_ExMAX'));
					Debug.logTrace("Ur a god, she's falling on ur arms rn *pog*");
				}
				else
				{
					dialogue = CoolUtil.coolTextFile(Paths.txt('data/songs/${PlayState.SONG.songId}/dialogue_end'));
					Debug.logTrace("Skill issue ur not enough CHAD to deserve her.");
				}
				var doofend = new DialogueBox(false, dialogue);
				doofend.scrollFactor.set();
				doofend.finishThing = endSong;
				doofend.cameras = [mainCam];
				coolIntro(doofend, false);
			}
			else
			{
				#if FEATURE_DISCORD
				if (FlxG.save.data.scoreScreen)
				{
					if (FlxG.save.data.discordMode != 0)
						DiscordClient.changePresence('RESULTS SCREEN -- ' + songFixedName + " (" + storyDifficultyText + " " + songMultiplier + "x" + ") "
							+ Ratings.GenerateComboRank(accuracy) + " " + Ratings.GenerateLetterRank(accuracy),
							"\nScr: " + songScore + " ("
							+ HelperFunctions.truncateFloat(accuracy, 2) + "%)" + " | Misses: " + misses, iconRPC);
					else
						DiscordClient.changePresence('RESULTS SCREEN -- ' + songFixedName + " (" + storyDifficultyText + " " + songMultiplier + "x" + ") ",
							iconRPC);
				}
				#end
				if (isStoryMode)
				{
					campaignScore += Math.round(songScore);
					campaignMisses += misses;
					campaignSicks += sicks;
					campaignGoods += goods;
					campaignBads += bads;
					campaignShits += shits;

					storyPlaylist.remove(storyPlaylist[0]);

					if (storyPlaylist.length <= 0)
					{
						paused = true;
						FlxG.sound.music.stop();
						vocals.stop();
						if (FlxG.save.data.scoreScreen)
						{
							openSubState(new ResultsScreen());
							new FlxTimer().start(1, function(tmr:FlxTimer)
							{
								inResults = true;
							});
						}
						else
						{
							GameplayCustomizeState.freeplayBf = 'bf';
							GameplayCustomizeState.freeplayDad = 'dad';
							GameplayCustomizeState.freeplayGf = 'gf';
							GameplayCustomizeState.freeplayNoteStyle = 'normal';
							GameplayCustomizeState.freeplayStage = 'stage';
							GameplayCustomizeState.freeplaySong = 'bopeebo';
							GameplayCustomizeState.freeplayWeek = 1;
							PsychTransition.nextCamera = mainCam;
							if (FlxTransitionableState.skipNextTransIn)
							{
								PsychTransition.nextCamera = null;
							}
							FlxG.sound.playMusic(Paths.music('freakyMenu'));
							MusicBeatState.switchState(new StoryMenuState());
							clean();
						}

						#if FEATURE_LUAMODCHART
						if (luaModchart != null)
						{
							luaModchart.die();
							luaModchart = null;
						}
						#end

						if (SONG.validScore)
						{
							Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
						}

						if ((PlayState.storyDifficulty == 2 || PlayState.storyDifficulty == 4)
							|| (PlayState.storyWeek == 1 && (PlayState.storyDifficulty == 0 || PlayState.storyDifficulty == 1)))
							StoryMenuState.unlockNextWeek(storyWeek);

						if (!FlxG.save.data.hiveUnlocked)
							FlxG.save.data.hiveUnlocked = true;
					}
					else
					{
						var diff:String = ["-novice", "-advanced", "-exhaust", "-maximum", "-heavenly"][storyDifficulty];

						Debug.logInfo('PlayState: Loading next story song ${PlayState.storyPlaylist[0]}-${diff}');

						if (StringTools.replace(PlayState.storyPlaylist[0], " ", "-").toLowerCase() == 'eggnog')
						{
							var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
								-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
							blackShit.scrollFactor.set();
							add(blackShit);
							camHUD.visible = false;

							FlxG.sound.play(Paths.sound('Lights_Shut_off'));
						}

						FlxTransitionableState.skipNextTransIn = true;
						FlxTransitionableState.skipNextTransOut = true;
						prevCamFollow = camFollow;

						PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0], diff);
						FlxG.sound.music.stop();

						LoadingState.loadAndSwitchState(new PlayState());
						clean();
					}
				}
				else
				{
					trace('WENT BACK TO FREEPLAY??');

					paused = true;

					FlxG.sound.music.stop();
					vocals.stop();

					if (FlxG.save.data.scoreScreen)
					{
						openSubState(new ResultsScreen());
						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							inResults = true;
						});
					}
					else
					{
						PsychTransition.nextCamera = mainCam;
						if (FlxTransitionableState.skipNextTransIn)
						{
							PsychTransition.nextCamera = null;
						}
						MusicBeatState.switchState(new FreeplayState());
						clean();
					}
				}
			}
		}
	}

	public var endingSong:Bool = false;

	var hits:Array<Float> = [];
	var offsetTest:Float = 0;

	public function getRatesScore(rate:Float, score:Float):Float
	{
		var rateX:Float = 1;
		var lastScore:Float = score;
		var pr = rate - 0.05;
		if (pr < 1.00)
			pr = 1;

		while (rateX <= pr)
		{
			if (rateX > pr)
				break;
			lastScore = score + ((lastScore * rateX) * 0.022);
			rateX += 0.05;
		}

		var actualScore = Math.round(score + (Math.floor((lastScore * pr)) * 0.022));

		return actualScore;
	}

	var timeShown = 0;
	var currentTimingShown:FlxText = null;

	private function popUpScore(daNote:Note = null):Void
	{
		var noteDiff:Float = (daNote.strumTime - Conductor.songPosition) + FlxG.save.data.offset + songOffset;
		var noteDiffAbs = Math.abs(noteDiff);

		if (!PlayStateChangeables.botPlay || loadRep)
			rating.visible = true;
		else
		{
			rating.visible = false;
		}
		rating.alpha = 1;

		FlxTween.cancelTweensOf(rating.scale);
		FlxTween.cancelTweensOf(rating);

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';
		var pixelShitPart3:String = null;

		var daRating = Ratings.judgeNote(noteDiffAbs);

		if (SONG.noteStyle == 'pixel')
		{
			pixelShitPart1 = 'weeb/pixelUI/';
			pixelShitPart2 = '-pixel';
			pixelShitPart3 = 'week6';
		}
		if (!PlayStateChangeables.botPlay || loadRep)
		{
			rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2, pixelShitPart3));
		}

		var wife:Float = 0;

		if (!daNote.isSustainNote)
			wife = EtternaFunctions.wife3(noteDiffAbs, Conductor.timeScale);

		// boyfriend.playAnim('hey');
		vocals.volume = 1;
		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		coolText.y -= 350;
		coolText.cameras = [camHUD];
		//
		var score:Float = 0;
		if (FlxG.save.data.accuracyMod == 1)
			totalNotesHit += wife;

		switch (daRating)
		{
			case 'shit':
				score = -300;
				combo = 0;
				misses++;
				if (!PlayStateChangeables.opponentMode)
					health -= 0.2 * PlayStateChangeables.healthLoss;
				else
					health += 0.2 * PlayStateChangeables.healthLoss;
				ss = false;
				shits++;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit -= 1;
			case 'bad':
				daRating = 'bad';
				score = 0;
				if (!PlayStateChangeables.opponentMode)
					health -= 0.06 * PlayStateChangeables.healthLoss;
				else
					health += 0.06 * PlayStateChangeables.healthLoss;
				ss = false;
				bads++;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit += 0.50;
			case 'good':
				daRating = 'good';
				score = 200;
				ss = false;
				goods++;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit += 0.75;
			case 'sick':
				score = 350;
				if (!PlayStateChangeables.opponentMode && health < 2)
				{
					health += 0.04 * PlayStateChangeables.healthGain;
				}
				else if (PlayStateChangeables.opponentMode && health > 0)
				{
					health -= 0.04 * PlayStateChangeables.healthGain;
				}
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit += 1;
				sicks++;
		}

		if (songMultiplier >= 1.05)
			score = getRatesScore(songMultiplier, score);

		// trace('Wife accuracy loss: ' + wife + ' | Rating: ' + daRating + ' | Score: ' + score + ' | Weight: ' + (1 - wife));

		songScore += Math.round(score);

		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		 */

		rating.screenCenter();
		rating.y -= 50;
		rating.x = coolText.x - 125;

		if (FlxG.save.data.changedHit)
		{
			rating.x = FlxG.save.data.changedHitX;
			rating.y = FlxG.save.data.changedHitY;
		}
		// rating.acceleration.y = 550;
		// rating.velocity.y -= FlxG.random.int(140, 175);
		// rating.velocity.x -= FlxG.random.int(0, 10);

		msTiming = HelperFunctions.truncateFloat(noteDiff, 3);
		if (PlayStateChangeables.botPlay && !loadRep)
			msTiming = 0;

		if (loadRep)
			msTiming = HelperFunctions.truncateFloat(findByTime(daNote.strumTime)[3], 3);

		if (currentTimingShown != null)
			remove(currentTimingShown);

		currentTimingShown = new FlxText(0, 0, 0, "0ms");
		timeShown = 0;
		if (!daNote.isSustainNote)
		{
			switch (daRating)
			{
				case 'shit':
					currentTimingShown.color = FlxColor.RED;
				case 'bad':
					currentTimingShown.color = FlxColor.fromString('#9efff5');
				case 'good':
					currentTimingShown.color = FlxColor.YELLOW;
				case 'sick':
					currentTimingShown.color = FlxColor.fromString('#00CEF1');
			}
			currentTimingShown.borderStyle = OUTLINE;
			currentTimingShown.borderSize = 1;
			currentTimingShown.borderColor = FlxColor.BLACK;
			currentTimingShown.fieldWidth = FlxG.initialWidth;
			currentTimingShown.text = msTiming + "ms";
			currentTimingShown.size = 20;

			if (msTiming >= 0.03 && offsetTesting)
			{
				// Remove Outliers
				hits.shift();
				hits.shift();
				hits.shift();
				hits.pop();
				hits.pop();
				hits.pop();
				hits.push(msTiming);

				var total = 0.0;

				for (i in hits)
					total += i;

				offsetTest = HelperFunctions.truncateFloat(total / hits.length, 2);
			}

			if (currentTimingShown.alpha != 1)
				currentTimingShown.alpha = 1;

			if (!PlayStateChangeables.botPlay || loadRep)
				add(currentTimingShown);
		}

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2, pixelShitPart3));
		comboSpr.screenCenter();
		comboSpr.x = rating.x;
		comboSpr.y = rating.y + 100;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;

		currentTimingShown.screenCenter();
		currentTimingShown.x = comboSpr.x + 58;
		currentTimingShown.y = rating.y + 65;
		// currentTimingShown.acceleration.y = 600;
		// currentTimingShown.velocity.y -= 150;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		// currentTimingShown.velocity.x += comboSpr.velocity.x;

		if (SONG.noteStyle != 'pixel')
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = FlxG.save.data.antialiasing;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = FlxG.save.data.antialiasing;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * CoolUtil.daPixelZoom * 0.7));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * CoolUtil.daPixelZoom * 0.7));
		}

		currentTimingShown.updateHitbox();
		comboSpr.updateHitbox();
		rating.updateHitbox();

		currentTimingShown.cameras = [camHUD];
		comboSpr.cameras = [camHUD];

		/* 
			trace(combo);
			trace(seperatedScore);
		 */

		// coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating.scale, {x: 0.45, y: 0.45}, 0.25, {});
		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001,
			onUpdate: function(tween:FlxTween)
			{
				if (currentTimingShown != null)
					currentTimingShown.alpha -= 0.02;
				timeShown++;
			}
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				if (currentTimingShown != null && timeShown >= 20)
				{
					remove(currentTimingShown);
					currentTimingShown = null;
				}
			},
			startDelay: Conductor.crochet * 0.001
		});

		curSection += 1;
	}

	function popUpNumbers(daNote:Note = null):Void
	{
		comboSprGroup.clear();
		var seperatedScore:Array<Int> = [];

		var comboSplit:Array<String> = (combo + "").split('');

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';
		var pixelShitPart3:String = null;

		if (combo > highestCombo)
			highestCombo = combo;

		// make sure we have 3 digits to display (looks weird otherwise lol)
		if (comboSplit.length == 1)
		{
			seperatedScore.push(0);
			seperatedScore.push(0);
		}
		else if (comboSplit.length == 2)
			seperatedScore.push(0);

		for (i in 0...comboSplit.length)
		{
			var str:String = comboSplit[i];
			seperatedScore.push(Std.parseInt(str));
		}
		var ciphers:Int = 0;
		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2, pixelShitPart3));
			numScore.alpha = 1;

			numScore.screenCenter();
			numScore.x = rating.x + (43 * daLoop) + 57;
			numScore.y = rating.y + 100;
			numScore.cameras = [camHUD];

			if (combo >= 1000)
			{
				numScore.x = rating.x + (43 * daLoop) + 52;
			}

			FlxTween.cancelTweensOf(numScore);
			FlxTween.cancelTweensOf(numScore.scale);

			if (SONG.noteStyle != 'pixel')
			{
				numScore.antialiasing = FlxG.save.data.antialiasing;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * CoolUtil.daPixelZoom));
			}
			numScore.updateHitbox();

			// numScore.acceleration.y = FlxG.random.int(200, 300);
			// numScore.velocity.y -= FlxG.random.int(140, 160);
			// numScore.velocity.x = FlxG.random.float(-5, 5);

			visibleCombos.push(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.25, {startDelay: Conductor.crochet * 0.001});

			FlxTween.tween(numScore.scale, {x: 0.45, y: 0.45}, 0.25, {});

			if (visibleCombos.length > seperatedScore.length + 20)
			{
				for (i in 0...seperatedScore.length - 1)
				{
					visibleCombos.remove(visibleCombos[visibleCombos.length - 1]);
				}
			}

			comboSprGroup.add(numScore);

			daLoop++;
		}
	}

	public function NearlyEquals(value1:Float, value2:Float, unimportantDifference:Float = 10):Bool
	{
		return Math.abs(FlxMath.roundDecimal(value1, 1) - FlxMath.roundDecimal(value2, 1)) < unimportantDifference;
	}

	var upHold:Bool = false;
	var downHold:Bool = false;
	var rightHold:Bool = false;
	var leftHold:Bool = false;

	// THIS FUNCTION JUST FUCKS WIT HELD NOTES AND BOTPLAY/REPLAY (also gamepad shit)

	private function keyShit():Void // I've invested in emma stocks
	{
		// control arrays, order L D R U
		var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
		var pressArray:Array<Bool> = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];
		var releaseArray:Array<Bool> = [controls.LEFT_R, controls.DOWN_R, controls.UP_R, controls.RIGHT_R];
		var keynameArray:Array<String> = ['left', 'down', 'up', 'right'];

		#if FEATURE_LUAMODCHART
		if (luaModchart != null)
		{
			for (i in 0...pressArray.length)
			{
				if (pressArray[i] == true)
				{
					luaModchart.executeState('keyPressed', [keynameArray[i]]);
				}
			};

			for (i in 0...releaseArray.length)
			{
				if (releaseArray[i] == true)
				{
					luaModchart.executeState('keyReleased', [keynameArray[i]]);
				}
			};
		};
		#end

		// Prevent player input if botplay is on
		if (PlayStateChangeables.botPlay)
		{
			holdArray = [false, false, false, false];
			pressArray = [false, false, false, false];
			releaseArray = [false, false, false, false];
		}

		var anas:Array<Ana> = [null, null, null, null];

		var daHitSound:FlxSound = new FlxSound().loadEmbedded(Paths.sound('hitsounds/${HitSounds.getSoundByID(FlxG.save.data.hitSound).toLowerCase()}',
			'shared'));
		daHitSound.volume = FlxG.save.data.hitVolume;
		if (FlxG.save.data.hitSound != 0 && pressArray.contains(true))
		{
			daHitSound.play();
		}

		for (i in 0...pressArray.length)
			if (pressArray[i])
				anas[i] = new Ana(Conductor.songPosition, null, false, "miss", i);

		// HOLDS, check for sustain notes
		if (holdArray.contains(true) && /*!boyfriend.stunned && */ generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData] && daNote.sustainActive)
				{
					goodNoteHit(daNote);
				}
			});
		}

		if ((KeyBinds.gamepad && !FlxG.keys.justPressed.ANY))
		{
			// PRESSES, check for note hits
			if (pressArray.contains(true) && generatedMusic)
			{
				if (!PlayStateChangeables.opponentMode)
					boyfriend.holdTimer = 0;
				else
					dad.holdTimer = 0;

				var possibleNotes:Array<Note> = []; // notes that can be hit
				var directionList:Array<Int> = []; // directions that can be hit
				var dumbNotes:Array<Note> = []; // notes to kill later
				var directionsAccounted:Array<Bool> = [false, false, false, false]; // we don't want to do judgments for more than one presses

				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit
						&& daNote.mustPress
						&& !daNote.wasGoodHit
						&& !directionsAccounted[daNote.noteData]
						&& !daNote.tooLate)
					{
						if (directionList.contains(daNote.noteData))
						{
							directionsAccounted[daNote.noteData] = true;
							for (coolNote in possibleNotes)
							{
								if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
								{ // if it's the same note twice at < 10ms distance, just delete it
									// EXCEPT u cant delete it in this loop cuz it fucks with the collection lol
									dumbNotes.push(daNote);
									break;
								}
								else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
								{ // if daNote is earlier than existing note (coolNote), replace
									possibleNotes.remove(coolNote);
									possibleNotes.push(daNote);
									break;
								}
							}
						}
						else
						{
							directionsAccounted[daNote.noteData] = true;
							possibleNotes.push(daNote);
							directionList.push(daNote.noteData);
						}
					}
				});

				for (note in dumbNotes)
				{
					FlxG.log.add("killing dumb ass note at " + note.strumTime);
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}

				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				var hit = [false, false, false, false];

				if (perfectMode)
					goodNoteHit(possibleNotes[0]);
				else if (possibleNotes.length > 0)
				{
					if (!FlxG.save.data.ghost)
					{
						for (shit in 0...pressArray.length)
						{ // if a direction is hit that shouldn't be
							if (pressArray[shit] && !directionList.contains(shit))
								noteMiss(shit, null);
						}
					}
					for (coolNote in possibleNotes)
					{
						if (pressArray[coolNote.noteData] && !hit[coolNote.noteData])
						{
							if (mashViolations != 0)
								mashViolations--;
							hit[coolNote.noteData] = true;
							scoreTxt.color = FlxColor.WHITE;
							var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
							anas[coolNote.noteData].hit = true;
							anas[coolNote.noteData].hitJudge = Ratings.judgeNote(noteDiff);
							anas[coolNote.noteData].nearestNote = [coolNote.strumTime, coolNote.noteData, coolNote.sustainLength];
							goodNoteHit(coolNote);
						}
					}
				};

				if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || PlayStateChangeables.botPlay))
				{
					if (boyfriend.animation.curAnim.name.startsWith('sing')
						&& !boyfriend.animation.curAnim.name.endsWith('miss')
						&& !FlxG.save.data.optimize
						&& !bfAllowedtoAnim)
						boyfriend.dance();
					camX = 0;
					camY = 0;
				}

				if (dad.holdTimer > Conductor.stepCrochet * 4 * 0.001
					&& (!holdArray.contains(true) || PlayStateChangeables.botPlay)
					&& opponentAllowedtoAnim)
				{
					if (!FlxG.save.data.optimize
						&& dad.animation.curAnim.name.startsWith('sing')
						&& dad.animation.curAnim.finished
						&& !dad.animation.curAnim.name.endsWith('miss'))
					{
						dad.dance();
						camX = 0;
						camY = 0;
					}
				}

				if (!FlxG.save.data.ghost)
				{
					for (shit in 0...pressArray.length)
						if (pressArray[shit])
							noteMiss(shit, null);
				}
			}

			if (!loadRep)
				for (i in anas)
					if (i != null)
						replayAna.anaArray.push(i); // put em all there
		}
		if (PlayStateChangeables.botPlay)
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.mustPress && Conductor.songPosition >= daNote.strumTime)
				{
					// Force good note hit regardless if it's too late to hit it or not as a fail safe
					if (loadRep)
					{
						// trace('ReplayNote ' + tmpRepNote.strumtime + ' | ' + tmpRepNote.direction);
						var n = findByTime(daNote.strumTime);
						trace(n);
						if (n != null)
						{
							goodNoteHit(daNote);
							if (!PlayStateChangeables.opponentMode)
								boyfriend.holdTimer = 0;
							else
								dad.holdTimer = 0;
						}
					}
					else
					{
						goodNoteHit(daNote);
						if (!PlayStateChangeables.opponentMode)
							boyfriend.holdTimer = 0;
						else
							dad.holdTimer = 0;
					}
				}
			});

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || PlayStateChangeables.botPlay))
		{
			camX = 0;
			camY = 0;
			if (boyfriend.animation.curAnim.name.startsWith('sing')
				&& !boyfriend.animation.curAnim.name.endsWith('miss')
				&& (boyfriend.animation.curAnim.curFrame >= 10 || boyfriend.animation.curAnim.finished)
				&& !FlxG.save.data.optimize
				&& bfAllowedtoAnim)
			{
				boyfriend.dance();
			}
		}

		if (!FlxG.save.data.optimize)
		{
			if (dad.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || PlayStateChangeables.botPlay))
			{
				camX = 0;
				camY = 0;
				if (opponentAllowedtoAnim)
				{
					if (dad.animation.curAnim.name.startsWith('sing')
						&& dad.animation.curAnim.finished
						&& !dad.animation.curAnim.name.endsWith('miss'))
					{
						dad.dance();
					}
				}
			}
		}

		playerStrums.forEach(function(spr:StaticArrow)
		{
			if (!PlayStateChangeables.botPlay)
			{
				if (keys[spr.ID]
					&& spr.animation.curAnim.name != 'confirm'
					&& spr.animation.curAnim.name != 'pressed'
					&& !spr.animation.curAnim.name.startsWith('dirCon'))
					spr.playAnim('pressed', false);
				if (!keys[spr.ID])
					spr.playAnim('static', false);
			}
			else if (FlxG.save.data.cpuStrums)
			{
				if (spr.animation.finished)
					spr.playAnim('static');
			}
		});
	}

	public function findByTime(time:Float):Array<Dynamic>
	{
		for (i in rep.replay.songNotes)
		{
			// trace('checking ' + Math.round(i[0]) + ' against ' + Math.round(time));
			if (i[0] == time)
				return i;
		}
		return null;
	}

	public function findByTimeIndex(time:Float):Int
	{
		for (i in 0...rep.replay.songNotes.length)
		{
			// trace('checking ' + Math.round(i[0]) + ' against ' + Math.round(time));
			if (rep.replay.songNotes[i][0] == time)
				return i;
		}
		return -1;
	}

	public var fuckingVolume:Float = 1;
	public var useVideo = false;

	public static var webmHandler:WebmHandler;

	public var playingDathing = false;

	public var videoSprite:FlxSprite;

	public function backgroundVideo(source:String) // for background videos
	{
		#if FEATURE_WEBM
		useVideo = true;

		var ourSource:String = "assets/videos/daWeirdVid/dontDelete.webm";
		// WebmPlayer.SKIP_STEP_LIMIT = 90;
		var str1:String = "WEBM SHIT";
		webmHandler = new WebmHandler();
		webmHandler.source(ourSource);
		webmHandler.makePlayer();
		webmHandler.webm.name = str1;

		GlobalVideo.setWebm(webmHandler);

		GlobalVideo.get().source(source);
		GlobalVideo.get().clearPause();
		if (GlobalVideo.isWebm)
		{
			GlobalVideo.get().updatePlayer();
		}
		GlobalVideo.get().show();

		if (GlobalVideo.isWebm)
		{
			GlobalVideo.get().restart();
		}
		else
		{
			GlobalVideo.get().play();
		}

		var data = webmHandler.webm.bitmapData;

		videoSprite = new FlxSprite(-470, -30).loadGraphic(data);

		videoSprite.setGraphicSize(Std.int(videoSprite.width * 1.2));

		remove(gf);
		remove(boyfriend);
		remove(dad);
		add(videoSprite);
		add(gf);
		add(boyfriend);
		add(dad);

		trace('poggers');

		if (!songStarted)
			webmHandler.pause();
		else
			webmHandler.resume();
		#end
	}

	function noteMiss(direction:Int = 1, daNote:Note):Void
	{
		if (!boyfriend.stunned)
		{
			vocals.volume = 0;
			if (PlayStateChangeables.skillIssue)
				if (!PlayStateChangeables.opponentMode)
					health = 0;
				else
					health = 2.1;
			// health -= 0.15;
			if (combo > 5 && gf.animOffsets.exists('sad') && allowedToCheer)
			{
				gf.playAnim('sad');
			}
			if (combo != 0)
			{
				combo = 0;
			}
			misses++;

			if (daNote != null)
			{
				if (!loadRep)
				{
					saveNotes.push([
						daNote.strumTime,
						0,
						direction,
						-(166 * Math.floor((PlayState.rep.replay.sf / 60) * 1000) / 166)
					]);
					saveJudge.push("miss");
				}
			}
			else if (!loadRep)
			{
				saveNotes.push([
					Conductor.songPosition,
					0,
					direction,
					-(166 * Math.floor((PlayState.rep.replay.sf / 60) * 1000) / 166)
				]);
				saveJudge.push("miss");
			}

			totalNotesHit -= 0.5;

			if (daNote != null)
			{
				if (!daNote.isSustainNote)
					songScore -= 10;
			}
			else
				songScore -= 10;

			if (FlxG.save.data.missSounds)
			{
				FlxG.sound.play(Paths.soundRandom('missnote' + altSuffix, 1, 3), FlxG.random.float(0.1, 0.2));
				// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
				// FlxG.log.add('played imss note');
			}

			// Hole switch statement replaced with a single line :)
			if (!FlxG.save.data.optimize && bfAllowedtoAnim)
			{
				if (!PlayStateChangeables.opponentMode)
					boyfriend.playAnim('sing' + dataSuffix[direction] + 'miss', true);
				else if (PlayStateChangeables.opponentMode && dad.curCharacter.toLowerCase() == 'pico')
					dad.playAnim('sing' + dataSuffix[direction] + 'miss', true);
			}

			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
				luaModchart.executeState('playerOneMiss', [direction, Conductor.songPosition]);
			#end

			updateAccuracy();
		}
	}

	/*function badNoteCheck()
		{
			// just double pasting this shit cuz fuk u
			// REDO THIS SYSTEM!
			var upP = controls.UP_P;
			var rightP = controls.RIGHT_P;
			var downP = controls.DOWN_P;
			var leftP = controls.LEFT_P;

			if (leftP)
				noteMiss(0);
			if (upP)
				noteMiss(2);
			if (rightP)
				noteMiss(3);
			if (downP)
				noteMiss(1);
			updateAccuracy();
		}
	 */
	function updateAccuracy()
	{
		updatedAcc = true;
		totalPlayed += 1;
		accuracy = Math.max(0, totalNotesHit / totalPlayed * 100);
		accuracyDefault = Math.max(0, totalNotesHitDefault / totalPlayed * 100);

		scoreTxt.visible = true;
		judgementCounter.text = 'S-Criticals: ${sicks}\nCriticals: ${goods}\nNears: ${bads}\nErrors: ${shits}\nMisses: ${misses}';

		if (!FlxG.save.data.lerpScore)
			scoreTxt.text = Ratings.CalculateRanking(songScore, songScoreDef, nps, maxNPS,
				(FlxG.save.data.roundAccuracy ? FlxMath.roundDecimal(accuracy, 0) : accuracy));

		#if FEATURE_DISCORD
		// Updating Discord Rich Presence
		if (FlxG.save.data.discordMode == 3)
			DiscordClient.changePresence(songFixedName + " (" + storyDifficultyText + " " + songMultiplier + "x" + ") "
				+ Ratings.GenerateComboRank(accuracy) + " " + Ratings.GenerateLetterRank(accuracy),
				"\nScr: " + songScore + " ("
				+ HelperFunctions.truncateFloat(accuracy, 2) + "%)" + " | Misses: " + misses, iconRPC);
		#end
	}

	function getKeyPresses(note:Note):Int
	{
		var possibleNotes:Array<Note> = []; // copypasted but you already know that

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
			{
				possibleNotes.push(daNote);
				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
			}
		});
		if (possibleNotes.length == 1)
			return possibleNotes.length + 1;
		return possibleNotes.length;
	}

	var mashing:Int = 0;
	var mashViolations:Int = 0;

	var etternaModeScore:Int = 0;

	function noteCheck(controlArray:Array<Bool>, note:Note):Void // sorry lol
	{
		var noteDiff:Float = -(note.strumTime - Conductor.songPosition);

		note.rating = Ratings.judgeNote(noteDiff);

		/* if (loadRep)
			{
				if (controlArray[note.noteData])
					goodNoteHit(note, false);
				else if (rep.replay.keyPresses.length > repPresses && !controlArray[note.noteData])
				{
					if (NearlyEquals(note.strumTime,rep.replay.keyPresses[repPresses].time, 4))
					{
						goodNoteHit(note, false);
					}
				}
		}*/

		if (controlArray[note.noteData])
		{
			goodNoteHit(note, (mashing > getKeyPresses(note)));

			/*if (mashing > getKeyPresses(note) && mashViolations <= 2)
				{
					mashViolations++;

					goodNoteHit(note, (mashing > getKeyPresses(note)));
				}
				else if (mashViolations > 2)
				{
					// this is bad but fuck you
					playerStrums.members[0].animation.play('static');
					playerStrums.members[1].animation.play('static');
					playerStrums.members[2].animation.play('static');
					playerStrums.members[3].animation.play('static');
					health -= 0.4;
					trace('mash ' + mashing);
					if (mashing != 0)
						mashing = 0;
				}
				else
					goodNoteHit(note, false); */
		}
	}

	function goodNoteHit(note:Note, resetMashViolation = true):Void
	{
		if (mashing != 0)
			mashing = 0;

		var noteDiff:Float = -(note.strumTime - Conductor.songPosition);

		if (loadRep)
		{
			noteDiff = findByTime(note.strumTime)[3];
			note.rating = rep.replay.songJudgements[findByTimeIndex(note.strumTime)];
		}
		else
			note.rating = Ratings.judgeNote(noteDiff);

		if (note.rating == "miss")
			return;

		// add newest note to front of notesHitArray
		// the oldest notes are at the end and are removed first
		if (!note.isSustainNote)
			notesHitArray.unshift(Date.now());

		if (!resetMashViolation && mashViolations >= 1)
			mashViolations--;

		if (mashViolations < 0)
			mashViolations = 0;

		if (!note.wasGoodHit)
		{
			combo += 1;
			popUpNumbers(note);
			if (!note.isSustainNote)
				popUpScore(note);

			switch (note.noteData)

			{
				case 3:
					camX = 20;
					camY = 0;

				case 2:
					camY = -20;
					camX = 0;

				case 1:
					camY = 20;
					camX = 0;
				case 0:
					camX = -20;
					camY = 0;
			}

			var altAnim:String = "";
			if (note.isAlt)
			{
				altAnim = '-alt';
			}

			if (!FlxG.save.data.optimize)
			{
				if (PlayStateChangeables.opponentMode && opponentAllowedtoAnim)
				{
					dad.playAnim('sing' + dataSuffix[note.noteData] + altAnim, true);
				}
				else if (bfAllowedtoAnim)
				{
					boyfriend.playAnim('sing' + dataSuffix[note.noteData] + altAnim, true);
				}
			}

			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
				luaModchart.executeState('playerOneSing', [note.noteData, Conductor.songPosition]);
			#end

			if (!loadRep && note.mustPress)
			{
				var array = [note.strumTime, note.sustainLength, note.noteData, noteDiff];
				if (note.isSustainNote)
					array[1] = -1;
				saveNotes.push(array);
				saveJudge.push(note.rating);
			}

			if (!PlayStateChangeables.botPlay || FlxG.save.data.cpuStrums)
			{
				playerStrums.forEach(function(spr:StaticArrow)
				{
					pressArrow(spr, spr.ID, note);
				});
			}

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
			else
			{
				note.wasGoodHit = true;
			}
			if (!note.isSustainNote)
				updateAccuracy();
		}
	}

	function pressArrow(spr:StaticArrow, idCheck:Int, daNote:Note)
	{
		if (Math.abs(daNote.noteData) == idCheck)
		{
			if (!FlxG.save.data.stepMania)
			{
				spr.playAnim('confirm', true);
			}
			else
			{
				spr.playAnim('dirCon' + daNote.originColor, true);
				spr.localAngle = daNote.originAngle;
			}
		}
	}

	var danced:Bool = false;

	override function stepHit()
	{
		super.stepHit();
		if (songMultiplier >= 1)
		{
			if (curStep % Math.floor(1 * songMultiplier) == 0)
			{
				if (Conductor.songPosition * songMultiplier > FlxG.sound.music.time + 25
					|| Conductor.songPosition * songMultiplier < FlxG.sound.music.time - 25)
				{
					resyncVocals();
				}
			}
		}

		// INTERLOPE SCROLL SPEED PULSE EFFECT SHIT (TESTING PURPOSES) --Credits to Hazard
		// Also check out tutorial modchart.lua that has this same tween but better :3
		/*if (curStep % Math.floor(4 * songMultiplier) == 0)
			{
				var scrollSpeedShit:Float = scrollSpeed;
				scrollSpeed /= scrollSpeed;
				scrollTween = FlxTween.tween(this, {scrollSpeed: scrollSpeedShit}, 0.25 / songMultiplier, {
					ease: FlxEase.sineOut,
					onComplete: function(twn:FlxTween)
					{
						scrollTween = null;
					}
				});
		}*/

		#if FEATURE_LUAMODCHART
		if (executeModchart && luaModchart != null)
		{
			luaModchart.setVar('curStep', curStep);
			luaModchart.executeState('stepHit', [curStep]);
		}
		#end

		if (!endingSong && currentSection != null)
		{
			if (!FlxG.save.data.optimize)
			{
				if (allowedToHeadbang && curStep % Math.floor(4 * songMultiplier) == 0)
				{
					gf.dance();
				}

				if (curStep % Math.floor(64 * songMultiplier) == Math.floor(60 * songMultiplier)
					&& SONG.songId == 'tutorial'
					&& dad.curCharacter == 'gf'
					&& curStep > 64 * songMultiplier
					&& curStep < 192 * songMultiplier)
				{
					if (vocals.volume != 0)
					{
						boyfriend.playAnim('hey', true);
						dad.playAnim('cheer', true);
					}
					else
					{
						dad.playAnim('sad', true);
						FlxG.sound.play(Paths.soundRandom('GF_', 1, 4, 'shared'), 0.3);
					}
				}
			}

			if (FlxG.save.data.optimize)
				if (vocals.volume == 0 && !currentSection.mustHitSection)
					vocals.volume = 1;
		}

		// HARDCODING FOR MILF ZOOMS!
		if (PlayState.SONG.songId == 'milf'
			&& curStep >= Math.floor(672 * songMultiplier)
			&& curStep < Math.floor(800 * songMultiplier)
			&& camZooming)
		{
			if (curStep % Math.floor(4 * songMultiplier) == 0)
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}
		}
		if (camZooming && FlxG.camera.zoom < 1.35 && curStep % Math.floor(16 * songMultiplier) == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		if (curStep % Math.floor(32 * songMultiplier) == Math.floor(28 * songMultiplier) && SONG.songId == 'bopeebo')
		{
			boyfriend.playAnim('hey', true);
		}

		if (SONG.songId == 'i' && curStep >= Std.int(1364 * songMultiplier) && curStep <= Std.int(1620 * songMultiplier))
		{
			if (curStep % Std.int(4 * songMultiplier) == 0 && camZooming)
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}
		}

		if (!FlxG.save.data.optimize && FlxG.save.data.background && FlxG.save.data.distractions)
		{
			if (SONG.songId == 'i' && Stage.curStage == 'voltexStage')
			{
				if (curStep == Std.int(1303 * songMultiplier))
				{
					lightsWentBRRR.alpha = 1;
					lightsWentBRRRnt.alpha = 1;
					littleLight.alpha = 1;
					lightsWentBRRR.animation.play('Sex', false, false, 0);
					littleLight.animation.play('Sex2', false, false, 0);
					opponentAllowedtoAnim = false;
				}
				if (curStep == Std.int(1352 * songMultiplier))
				{
					remove(dad);
					dad.destroy(); // :'v
					lightsWentBRRR.alpha = 0;
					littleLight.alpha = 0;
					lightsWentBRRRnt.animation.play('Sex3', false, false, 0);
				}
				if (curStep >= Std.int(1364 * songMultiplier))
				{
					lightsWentBRRR.destroy();
					littleLight.destroy();
					lightsWentBRRRnt.destroy();
				}
			}
		}
		else if (!FlxG.save.data.optimize && FlxG.save.data.background && !FlxG.save.data.distractions)
		{
			if (SONG.songId == 'i' && Stage.curStage == 'voltexStage')
			{
				if (curStep == Std.int(1303 * songMultiplier))
				{
					conalep_pc.alpha = 1;
					mainCam.fade(FlxColor.WHITE, 0.75 / songMultiplier, true);
					opponentAllowedtoAnim = false;
					remove(dad);
					dad.destroy();
				}
				if (curStep == Std.int(1352 * songMultiplier))
				{
					remove(dad);
					dad.destroy(); // :'v
					conalep_pc.alpha = 0;
					remove(conalep_pc);
					conalep_pc.destroy();
					mainCam.fade(FlxColor.WHITE, 0.75 / songMultiplier, true);
				}
			}
		}
	}

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, (PlayStateChangeables.useDownscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));
		}

		#if FEATURE_LUAMODCHART
		if (executeModchart && luaModchart != null)
		{
			luaModchart.executeState('beatHit', [curBeat]);
		}
		#end

		#if FEATURE_DISCORD
		if (FlxG.save.data.discordMode == 1)
		{
			DiscordClient.changePresence(songFixedName + " (" + storyDifficultyText + " " + songMultiplier + "x" + ") "
				+ Ratings.GenerateComboRank(accuracy) + " " + Ratings.GenerateLetterRank(accuracy),
				"\nScr: " + songScore + " ("
				+ HelperFunctions.truncateFloat(accuracy, 2) + "%)" + " | Misses: " + misses, iconRPC);
		}
		#end

		if (currentSection != null && !FlxG.save.data.optimize)
		{
			if (curBeat % idleBeat == 0)
			{
				if (opponentAllowedtoAnim)
					if (idleToBeat && !dad.animation.curAnim.name.startsWith('sing'))
						dad.dance(forcedToIdle, currentSection.CPUAltAnim);
				if (bfAllowedtoAnim)
					if (idleToBeat && !boyfriend.animation.curAnim.name.startsWith('sing'))
						boyfriend.dance(forcedToIdle, currentSection.playerAltAnim);
			}
			else if (curBeat % idleBeat != 0)
			{
				if (bfAllowedtoAnim)
					if (boyfriend.isDancing && !boyfriend.animation.curAnim.name.startsWith('sing'))
						boyfriend.dance(forcedToIdle, currentSection.CPUAltAnim);
				if (opponentAllowedtoAnim)
					if (dad.isDancing && !dad.animation.curAnim.name.startsWith('sing'))
						dad.dance(forcedToIdle, currentSection.CPUAltAnim);
			}
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);

		wiggleShit.update(Conductor.crochet);

		if (!endingSong)
		{
			iconP1.setGraphicSize(Std.int(iconP1.width + 45 / songMultiplier));
			iconP2.setGraphicSize(Std.int(iconP2.width + 45 / songMultiplier));

			iconP1.updateHitbox();
			iconP2.updateHitbox();
		}
	}

	public var cleanedSong:SongData;

	public function poggers(?cleanTheSong = false)
	{
		var notes = [];

		if (cleanTheSong)
		{
			cleanedSong = SONG;

			for (section in cleanedSong.notes)
			{
				var removed = [];

				for (note in section.sectionNotes)
				{
					// commit suicide
					var old = note[0];
					if (note[0] < section.startTime)
					{
						notes.push(note);
						removed.push(note);
					}
					if (note[0] > section.endTime)
					{
						notes.push(note);
						removed.push(note);
					}
				}

				for (i in removed)
				{
					section.sectionNotes.remove(i);
				}
			}

			for (section in cleanedSong.notes)
			{
				var saveRemove = [];

				for (i in notes)
				{
					if (i[0] >= section.startTime && i[0] < section.endTime)
					{
						saveRemove.push(i);
						section.sectionNotes.push(i);
					}
				}

				for (i in saveRemove)
					notes.remove(i);
			}

			trace("FUCK YOU BITCH FUCKER CUCK SUCK BITCH " + cleanedSong.notes.length);

			SONG = cleanedSong;
		}
		else
		{
			for (section in SONG.notes)
			{
				var removed = [];

				for (note in section.sectionNotes)
				{
					// commit suicide
					var old = note[0];
					if (note[0] < section.startTime)
					{
						notes.push(note);
						removed.push(note);
					}
					if (note[0] > section.endTime)
					{
						notes.push(note);
						removed.push(note);
					}
				}

				for (i in removed)
				{
					section.sectionNotes.remove(i);
				}
			}

			for (section in SONG.notes)
			{
				var saveRemove = [];

				for (i in notes)
				{
					if (i[0] >= section.startTime && i[0] < section.endTime)
					{
						saveRemove.push(i);
						section.sectionNotes.push(i);
					}
				}

				for (i in saveRemove)
					notes.remove(i);
			}

			trace("FUCK YOU BITCH FUCKER CUCK SUCK BITCH " + cleanedSong.notes.length);

			SONG = cleanedSong;
		}
	}

	public function updateSettings():Void
	{
		scoreTxt.y = healthBarBG.y;
		if (FlxG.save.data.colour)
			healthBar.createFilledBar(dad.barColor, boyfriend.barColor);
		else
			healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		healthBar.updateBar();
		if (!inCutscene)
		{
			laneunderlay.alpha = FlxG.save.data.laneTransparency;
			if (!FlxG.save.data.middleScroll)
				laneunderlayOpponent.alpha = FlxG.save.data.laneTransparency;
		}

		if (!isStoryMode)
			PlayStateChangeables.botPlay = FlxG.save.data.botplay;

		iconP1.kill();
		iconP2.kill();
		healthBar.kill();
		healthBarBG.kill();
		remove(healthBar);
		remove(iconP1);
		remove(iconP2);
		remove(healthBarBG);

		judgementCounter.kill();
		remove(judgementCounter);

		if (FlxG.save.data.judgementCounter)
		{
			judgementCounter.revive();
			add(judgementCounter);
		}

		if (songStarted)
		{
			songName.kill();
			songPosBar.kill();
			bar.kill();
			remove(bar);
			remove(songName);
			remove(songPosBar);
			songName.visible = FlxG.save.data.songPosition;
			songPosBar.visible = FlxG.save.data.songPosition;
			bar.visible = FlxG.save.data.songPosition;
			if (FlxG.save.data.songPosition)
			{
				songName.revive();
				songPosBar.revive();
				bar.revive();
				add(songPosBar);
				add(songName);
				add(bar);
				songName.alpha = 1;
				songPosBar.alpha = 0.85;
				bar.alpha = 1;
			}
		}

		if (!isStoryMode)
		{
			botPlayState.kill();
			remove(botPlayState);
			if (PlayStateChangeables.botPlay)
			{
				addedBotplay = true;
				botPlayState.revive();
				add(botPlayState);
			}
		}

		if (FlxG.save.data.healthBar)
		{
			healthBarBG.revive();
			healthBar.revive();
			iconP1.revive();
			iconP2.revive();
			add(healthBarBG);
			add(healthBar);
			add(iconP1);
			add(iconP2);
			scoreTxt.y = healthBarBG.y + 50;
		}
	}

	public function changeScrollSpeed(mult:Float, time:Float, ease):Void
	{
		var newSpeed = scrollSpeed * mult;
		if (time <= 0)
		{
			scrollSpeed *= newSpeed;
		}
		else
		{
			scrollTween = FlxTween.tween(this, {scrollSpeed: newSpeed}, time, {
				ease: ease,
				onComplete: function(twn:FlxTween)
				{
					scrollTween = null;
				}
			});
			scrollMult = mult;
		}
	}

	override function destroy()
	{
		super.destroy();
	}
} // u looked :O -ides

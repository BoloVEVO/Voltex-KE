package;

import openfl.utils.Future;
import openfl.media.Sound;
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
#if FEATURE_STEPMANIA
import smTools.SMFile;
#end
#if FEATURE_FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end
import Song.SongData;
import flixel.input.gamepad.FlxGamepad;
import flash.text.TextField;
import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import openfl.utils.Assets as OpenFlAssets;
#if FEATURE_DISCORD
import Discord.DiscordClient;
#end
import FreeplaySubState;
import Modifiers;

using StringTools;

class FreeplayState extends MusicBeatState
{
	public static var songs:Array<FreeplaySongMetadata> = [];

	var selector:FlxText;

	public static var rate:Float = 1.0;

	public static var curSelected:Int = 0;
	public static var curDifficulty:Int = 0;

	var scoreText:FlxText;
	var comboText:FlxText;
	var diffText:FlxText;

	public static var diffCalcText:FlxText;

	var previewtext:FlxText;
	var helpText:FlxText;
	var opponentText:FlxText;
	var lerpScore:Int = 0;
	var intendedaccuracy:Float = 0.00;
	var intendedScore:Int = 0;
	var letter:String;
	var combo:String = 'N/A';
	var lerpaccuracy:Float = 0.00;

	var intendedColor:Int;
	var colorTween:FlxTween;

	var bg:FlxSprite;

	var bgHive:FlxSprite; // For the bee girl :]

	var Inst:FlxSound;

	public static var openMod:Bool = false;

	private var grpSongs:FlxTypedGroup<Alphabet>;

	private static var curPlaying:Bool = false;

	public static var songText:Alphabet;

	private var iconArray:Array<HealthIcon> = [];

	public static var icon:HealthIcon;
	public static var openedPreview = false;

	public static var songData:Map<String, Array<SongData>> = [];

	public static function loadDiff(diff:Int, songId:String, array:Array<SongData>)
	{
		var diffName:String = "";

		switch (diff)
		{
			case 0:
				diffName = "-novice";
			case 1:
				diffName = "-advanced";
			case 2:
				diffName = "-exhaust";
			case 3:
				diffName = "-maximum";
			case 4:
				diffName = "-heavenly";
		}

		array.push(Song.conversionChecks(Song.loadFromJson(songId, diffName)));
	}

	public static var list:Array<String> = [];

	override function create()
	{
		Main.dumpCache();
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		list = CoolUtil.coolTextFile(Paths.txt('data/freeplaySonglist'));

		cached = false;

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			MainMenuState.freakyPlaying = true;
		}
		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bgHive = new FlxSprite().loadGraphic(Paths.image('Hive1'));
		bgHive.alpha = 0;

		populateSongData();
		PlayState.inDaPlay = false;
		PlayState.currentSong = "bruh";

		#if !FEATURE_STEPMANIA
		trace("FEATURE_STEPMANIA was not specified during build, sm file loading is disabled.");
		#elseif FEATURE_STEPMANIA
		// TODO: Refactor this to use OpenFlAssets.
		trace("tryin to load sm files");
		for (i in FileSystem.readDirectory("assets/sm/"))
		{
			trace(i);
			if (FileSystem.isDirectory("assets/sm/" + i))
			{
				trace("Reading SM file dir " + i);
				for (file in FileSystem.readDirectory("assets/sm/" + i))
				{
					if (file.contains(" "))
						FileSystem.rename("assets/sm/" + i + "/" + file, "assets/sm/" + i + "/" + file.replace(" ", "_"));
					if (file.endsWith(".sm") && !FileSystem.exists("assets/sm/" + i + "/converted.json"))
					{
						trace("reading " + file);
						var file:SMFile = SMFile.loadFile("assets/sm/" + i + "/" + file.replace(" ", "_"));
						trace("Converting " + file.header.TITLE);
						var data = file.convertToFNF("assets/sm/" + i + "/converted.json");
						var meta = new FreeplaySongMetadata(file.header.TITLE, 0, "sm", file, "assets/sm/" + i);
						songs.push(meta);
						var song = Song.loadFromJsonRAW(data);
						songData.set(file.header.TITLE, [song, song, song]);
					}
					else if (FileSystem.exists("assets/sm/" + i + "/converted.json") && file.endsWith(".sm"))
					{
						trace("reading " + file);
						var file:SMFile = SMFile.loadFile("assets/sm/" + i + "/" + file.replace(" ", "_"));
						trace("Converting " + file.header.TITLE);
						var data = file.convertToFNF("assets/sm/" + i + "/converted.json");
						var meta = new FreeplaySongMetadata(file.header.TITLE, 0, "sm", file, "assets/sm/" + i);
						songs.push(meta);
						var song = Song.loadFromJsonRAW(File.getContent("assets/sm/" + i + "/converted.json"));
						trace("got content lol");
						songData.set(file.header.TITLE, [song, song, song]);
					}
				}
			}
		}
		#end

		#if FEATURE_DISCORD
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Freeplay Menu", null);
		#end

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end

		persistentUpdate = true;

		// LOAD MUSIC

		if (FlxG.save.data.hiveUnlocked) // Already on PlayState.hx
		{
			addSong('bi', 1, 'Bi', '#d8544e');
		}
		if (FlxG.save.data.weekUnlocked > 1)
		{
			addSong('fin4le', 1, 'Tamarasis', '#d8544e');
		}

		// LOAD CHARACTERS
		bg.antialiasing = FlxG.save.data.antialiasing;
		add(bg);
		add(bgHive);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songFixedName = StringTools.replace(songs[i].songName, "-", " ");
			songText = new Alphabet(0, (70 * i) + 30, songFixedName, true, false, true);
			if (songs[i].songName == 'bi')
				songText = new Alphabet(0, (70 * i) + 30, 'び', true, false, true);

			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			icon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		scoreText = new FlxText(FlxG.width * 0.65, 5, 0, "", 32);
		// scoreText.autoSize = false;
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		// scoreText.alignment = RIGHT;

		var kadebigdick:String = "";
		if (FlxG.random.bool(0.1))
			kadebigdick = " / WTF AN OPTIMIZED KADE ENGINE????!!!!!";

		var bottomBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(Std.int(FlxG.width), 26, 0xFF000000);
		bottomBG.alpha = 0.6;
		add(bottomBG);

		var bottomText:String = "  Press SPACE to listen to the Song Instrumental / Your offset is "
			+ FlxG.save.data.offset
			+ "ms /"
			+ " Optimization is"
			+ (FlxG.save.data.optimize ? " Enabled" : " Disabled")
			+ kadebigdick;
		var downText:FlxText = new FlxText(bottomBG.x, bottomBG.y + 4, FlxG.width, bottomText, 16);
		downText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT);
		downText.scrollFactor.set();
		add(downText);

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.4), 337, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		comboText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		comboText.font = scoreText.font;
		add(comboText);

		opponentText = new FlxText(scoreText.x, scoreText.y + 66, 0, "", 24);
		opponentText.font = scoreText.font;
		add(opponentText);

		diffText = new FlxText(scoreText.x, scoreText.y + 106, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		diffCalcText = new FlxText(scoreText.x, scoreText.y + 136, 0, "", 24);
		diffCalcText.font = scoreText.font;
		add(diffCalcText);

		previewtext = new FlxText(scoreText.x, scoreText.y + 166, 0, "Rate: < " + FlxMath.roundDecimal(rate, 2) + "x >", 24);
		previewtext.font = scoreText.font;
		add(previewtext);

		helpText = new FlxText(scoreText.x, scoreText.y + 211, 0, "", 20);
		helpText.text = "LEFT-RIGHT to change Difficulty\n\n" + "SHIFT + LEFT-RIGHT to change Rate\n" + "if it's possible\n\n"
			+ "CTRL to open Gameplay Modifiers\n" + "";
		helpText.font = scoreText.font;
		helpText.color = 0xFFfaff96;
		add(helpText);

		add(scoreText);

		if (curSelected >= songs.length)
			curSelected = 0;
		bg.color = songs[curSelected].color;
		intendedColor = bg.color;

		if (!openMod)
		{
			changeSelection();
			changeDiff();
		}

		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);

		var swag:Alphabet = new Alphabet(1, 0, "swag");

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

		super.create();
	}

	override function closeSubState()
	{
		persistentUpdate = true;
		super.closeSubState();
	}

	public static var cached:Bool = false;

	/**
	 * Load song data from the data files.
	 */
	static function populateSongData()
	{
		cached = false;
		list = CoolUtil.coolTextFile(Paths.txt('data/freeplaySonglist'));

		songData = [];
		songs = [];

		for (i in 0...list.length)
		{
			var data:Array<String> = list[i].split(':');
			var songId = data[0];
			var color = data[3];

			if (color == null)
			{
				color = "#9271fd";
			}

			var meta = new FreeplaySongMetadata(songId, Std.parseInt(data[2]), data[1], FlxColor.fromString(color));

			var diffs = [];
			var diffsThatExist = [];

			#if FEATURE_FILESYSTEM
			if (Paths.doesTextAssetExist(Paths.json('songs/$songId/$songId-heavenly')))
				diffsThatExist.push("Heavenly");
			if (Paths.doesTextAssetExist(Paths.json('songs/$songId/$songId-maximum')))
				diffsThatExist.push("Maximum");
			if (Paths.doesTextAssetExist(Paths.json('songs/$songId/$songId-exhaust')))
				diffsThatExist.push("Exhaust");
			if (Paths.doesTextAssetExist(Paths.json('songs/$songId/$songId-advanced')))
				diffsThatExist.push("Advanced");
			if (Paths.doesTextAssetExist(Paths.json('songs/$songId/$songId-novice')))
				diffsThatExist.push("Novice");

			if (diffsThatExist.length == 0)
			{
				Debug.displayAlert(meta.songName + " Chart", "No difficulties found for chart, skipping.");
			}
			#else
			diffsThatExist = ["Novice", "Advanced", "Exhaust", "Maximum", "Heavenly"];
			#end

			if (diffsThatExist.contains("Novice"))
				FreeplayState.loadDiff(0, songId, diffs);
			if (diffsThatExist.contains("Advanced"))
				FreeplayState.loadDiff(1, songId, diffs);
			if (diffsThatExist.contains("Exhaust"))
				FreeplayState.loadDiff(2, songId, diffs);
			if (diffsThatExist.contains("Maximum"))
				FreeplayState.loadDiff(3, songId, diffs);
			if (diffsThatExist.contains("Heavenly"))
				FreeplayState.loadDiff(4, songId, diffs);

			meta.diffs = diffsThatExist;

			if (diffsThatExist.length != 5)
				trace("I ONLY FOUND " + diffsThatExist);

			FreeplayState.songData.set(songId, diffs);
			trace('loaded diffs for ' + songId);
			FreeplayState.songs.push(meta);

			/*#if FFEATURE_FILESYSTEM
				sys.thread.Thread.create(() ->
				{
					FlxG.sound.cache(Paths.inst(songId));
				});
				#else
				FlxG.sound.cache(Paths.inst(songId));
				#end */
		}
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:String)
	{
		var meta = new FreeplaySongMetadata(songName, weekNum, songCharacter, FlxColor.fromString(color));

		var diffs = [];
		var diffsThatExist = [];

		#if FEATURE_FILESYSTEM
		if (Paths.doesTextAssetExist(Paths.json('songs/$songName/$songName-heavenly')))
			diffsThatExist.push("Heavenly");
		if (Paths.doesTextAssetExist(Paths.json('songs/$songName/$songName-maximum')))
			diffsThatExist.push("Maximum");
		if (Paths.doesTextAssetExist(Paths.json('songs/$songName/$songName-exhaust')))
			diffsThatExist.push("Exhaust");
		if (Paths.doesTextAssetExist(Paths.json('songs/$songName/$songName-advanced')))
			diffsThatExist.push("Advanced");
		if (Paths.doesTextAssetExist(Paths.json('songs/$songName/$songName-novice')))
			diffsThatExist.push("Novice");

		if (diffsThatExist.length == 0)
		{
			Debug.displayAlert(meta.songName + " Chart", "No difficulties found for chart, skipping.");
		}
		#else
		diffsThatExist = ["Novice", "Advanced", "Exhaust", "Maximum", "Heavenly"];
		#end

		if (diffsThatExist.contains("Novice"))
			FreeplayState.loadDiff(0, songName, diffs);
		if (diffsThatExist.contains("Advanced"))
			FreeplayState.loadDiff(1, songName, diffs);
		if (diffsThatExist.contains("Exhaust"))
			FreeplayState.loadDiff(2, songName, diffs);
		if (diffsThatExist.contains("Maximum"))
			FreeplayState.loadDiff(3, songName, diffs);
		if (diffsThatExist.contains("Heavenly"))
			FreeplayState.loadDiff(4, songName, diffs);

		meta.diffs = diffsThatExist;

		if (diffsThatExist.length != 5)
			trace("I ONLY FOUND " + diffsThatExist);

		songData.set(songName, diffs);

		songs.push(meta);
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>, ?color:String)
	{
		if (songCharacters == null)
			songCharacters = ['dad'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num], color);

			if (songCharacters.length != 1)
				num++;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));
		lerpaccuracy = FlxMath.lerp(lerpaccuracy, intendedaccuracy, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1) / (openfl.Lib.current.stage.frameRate / 60));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		if (Math.abs(lerpaccuracy - intendedaccuracy) <= 0.001)
			lerpaccuracy = intendedaccuracy;

		scoreText.text = "PERSONAL BEST:" + lerpScore;
		if (combo == "")
		{
			comboText.text = "RANK: N/A";
			comboText.alpha = 0.5;
		}
		else
		{
			comboText.text = "RANK: " + letter + " | " + combo + " (" + HelperFunctions.truncateFloat(lerpaccuracy, 2) + "%)\n";
			comboText.alpha = 1;
		}
		opponentText.text = "OPPONENT MODE: " + (FlxG.save.data.opponent ? "ON" : "OFF");

		if (FlxG.sound.music.volume > 0.8)
		{
			FlxG.sound.music.volume -= 0.5 * FlxG.elapsed;
		}

		var upP = FlxG.keys.justPressed.UP;
		var downP = FlxG.keys.justPressed.DOWN;
		var accepted = FlxG.keys.justPressed.ENTER;
		var dadDebug = FlxG.keys.justPressed.SIX;
		var charting = FlxG.keys.justPressed.SEVEN;
		var bfDebug = FlxG.keys.justPressed.ZERO;

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (!openMod && !MusicBeatState.switchingState)
		{
			if (gamepad != null)
			{
				if (gamepad.justPressed.DPAD_UP)
				{
					changeSelection(-1);
				}
				if (gamepad.justPressed.DPAD_DOWN)
				{
					changeSelection(1);
				}
				if (gamepad.justPressed.DPAD_LEFT)
				{
					changeDiff(-1);
				}
				if (gamepad.justPressed.DPAD_RIGHT)
				{
					changeDiff(1);
				}

				/*if (gamepad.justPressed.X && !openedPreview)
					openSubState(new DiffOverview()); */
			}

			if (upP)
			{
				changeSelection(-1);
			}
			if (downP)
			{
				changeSelection(1);
			}
		}

		/*if (FlxG.keys.justPressed.X && !openedPreview)
			openSubState(new DiffOverview()); */

		previewtext.text = "Rate: " + FlxMath.roundDecimal(rate, 2) + "x";
		previewtext.alpha = 1;

		if (FlxG.keys.justPressed.CONTROL && !openMod && !MusicBeatState.switchingState)
		{
			openMod = true;
			FlxG.sound.play(Paths.sound('scrollMenu'));
			openSubState(new FreeplaySubState.ModMenu());
		}

		if (!openMod)
		{
			if (FlxG.keys.pressed.SHIFT) // && songs[curSelected].songName.toLowerCase() != "tutorial")
			{
				if (FlxG.keys.justPressed.LEFT)
				{
					rate -= 0.05;
					updateDiffCalc();
				}
				if (FlxG.keys.justPressed.RIGHT)
				{
					rate += 0.05;
					updateDiffCalc();
				}

				if (FlxG.keys.justPressed.R)
				{
					rate = 1;
					updateDiffCalc();
				}

				if (rate > 3)
				{
					rate = 3;
					updateDiffCalc();
				}
				else if (rate < 0.5)
				{
					rate = 0.5;
					updateDiffCalc();
				}

				previewtext.text = "Rate: < " + FlxMath.roundDecimal(rate, 2) + "x >";
			}
			else
			{
				if (FlxG.keys.justPressed.LEFT)
					changeDiff(-1);
				if (FlxG.keys.justPressed.RIGHT)
					changeDiff(1);
			}

			if (FlxG.keys.justPressed.SPACE)
			{
				FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0.7, true);
				MainMenuState.freakyPlaying = false;
			}
		}

		#if cpp
		@:privateAccess
		{
			if (FlxG.sound.music.playing && !MainMenuState.freakyPlaying)
				lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, rate);
		}
		#end

		/*if (songs[curSelected].songName.toLowerCase() == "tutorial")
			{
				previewtext.text = "Rate: Unavailable";
				previewtext.alpha = 0.5;
		}*/

		if (!openMod && !MusicBeatState.switchingState)
		{
			if (controls.BACK)
			{
				MusicBeatState.switchState(new MainMenuState());
				clean();
				if (colorTween != null)
				{
					colorTween.cancel();
				}
			}

			if (accepted)
				loadSong();
			else if (charting)
				loadSong(true);

			// AnimationDebug and StageDebug are only enabled in debug builds.
			#if debug
			if (dadDebug)
			{
				loadAnimDebug(true);
			}
			if (bfDebug)
			{
				loadAnimDebug(false);
			}
			#end
		}
	}

	public static function updateDiffCalc():Void
	{
		FreeplayState.diffCalcText.text = 'RATING: ${DiffCalc.CalculateDiff(songData.get(songs[curSelected].songName)[curDifficulty])}';
	}

	function loadAnimDebug(dad:Bool = true)
	{
		// First, get the song data.
		var hmm;
		try
		{
			hmm = songData.get(songs[curSelected].songName)[curDifficulty];
			if (hmm == null)
				return;
		}
		catch (ex)
		{
			return;
		}
		PlayState.SONG = hmm;

		var character = dad ? PlayState.SONG.player2 : PlayState.SONG.player1;

		LoadingState.loadAndSwitchState(new AnimationDebug(character));
	}

	function loadSong(isCharting:Bool = false)
	{
		loadSongInFreePlay(songs[curSelected].songName, curDifficulty, isCharting);
	}

	/**
	 * Load into a song in free play, by name.
	 * This is a static function, so you can call it anywhere.
	 * @param songName The name of the song to load. Use the human readable name, with spaces.
	 * @param isCharting If true, load into the Chart Editor instead.
	 */
	public static function loadSongInFreePlay(songName:String, difficulty:Int, isCharting:Bool, reloadSong:Bool = false)
	{
		// Make sure song data is initialized first.
		if (songData == null || Lambda.count(songData) == 0)
			populateSongData();

		var currentSongData;
		try
		{
			if (songData.get(songName) == null)
				return;
			currentSongData = songData.get(songName)[difficulty];
			if (songData.get(songName)[difficulty] == null)
				return;
		}
		catch (ex)
		{
			return;
		}

		PlayState.SONG = currentSongData;
		PlayState.isStoryMode = false;
		PlayState.storyDifficulty = difficulty;
		PlayState.storyWeek = songs[curSelected].week;
		Debug.logInfo('Loading song ${PlayState.SONG.songName} from week ${PlayState.storyWeek} into Free Play...');
		#if FEATURE_STEPMANIA
		if (songs[curSelected].songCharacter == "sm")
		{
			Debug.logInfo('Song is a StepMania song!');
			PlayState.isSM = true;
			PlayState.sm = songs[curSelected].sm;
			PlayState.pathToSm = songs[curSelected].path;
		}
		else
			PlayState.isSM = false;
		#else
		PlayState.isSM = false;
		#end

		PlayState.songMultiplier = rate;

		if (isCharting)
			LoadingState.loadAndSwitchState(new ChartingState(reloadSong));
		else
			LoadingState.loadAndSwitchState(new PlayState());
	}

	function changeDiff(?change:Int = 0)
	{
		if (songs[curSelected].songName != 'fin4le')
		{
			curDifficulty += change;
			if (curDifficulty < 0)
				curDifficulty = CoolUtil.difficultyArray.length - 2;
			if (curDifficulty >= CoolUtil.difficultyArray.length - 1)
				curDifficulty = 0;
		}

		/*if (!songs[curSelected].diffs.contains(CoolUtil.difficultyFromInt(curDifficulty)))
			return; */

		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");
		// adjusting the highscore song name to be compatible (changeDiff)
		switch (songHighscore)
		{
			case 'Dad-Battle':
				songHighscore = 'Dadbattle';
			case 'Philly-Nice':
				songHighscore = 'Philly';
			case 'M.I.L.F':
				songHighscore = 'Milf';
		}

		#if !switch
		intendedScore = Highscore.getScore(songHighscore, curDifficulty);
		combo = Highscore.getCombo(songHighscore, curDifficulty);
		letter = Highscore.getLetter(songHighscore, curDifficulty);
		intendedaccuracy = Highscore.getAcc(songHighscore, curDifficulty);
		#end
		updateDiffCalc();
		diffText.text = 'DIFFICULTY: < ' + CoolUtil.difficultyFromInt(curDifficulty, songs[curSelected].songName == 'fin4le').toUpperCase() + ' >';
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;
		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		if (songs[curSelected].songName == 'fin4le'
			&& curDifficulty > 0) // Exhaust and Heavenly diffs are dummy diffs that act like novice and advanced diffs. So to prevent crashes for not enough diffs we're doing this :)
		{
			curDifficulty = 0;
		}

		// This fucks diff change selector with custom Voltex diffs so I put this as a comment to test and worked lol.
		/*switch (songs[curSelected].diffs[0])
			{
				case "Novice":
					curDifficulty = 0;
				case "Advanced":
					curDifficulty = 1;
				case "Exhaust":
					curDifficulty = 2;
				case "Maximum":
					curDifficulty = 3;
				case "Heavenly":
					curDifficulty = 4;
		}*/
		/*if (songs[curSelected].songName.toLowerCase() == "tutorial")
			{
				rate = 1.0;
		}*/

		var newColor:Int = songs[curSelected].color;
		if (newColor != intendedColor)
		{
			if (colorTween != null)
			{
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 0.5, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween)
				{
					colorTween = null;
				}
			});
		}
		// selector.y = (70 * curSelected) + 30;

		// adjusting the highscore song name to be compatible (changeSelection)
		// would read original scores if we didn't change packages
		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");
		switch (songHighscore)
		{
			case 'Dad-Battle':
				songHighscore = 'Dadbattle';
			case 'Philly-Nice':
				songHighscore = 'Philly';
			case 'M.I.L.F':
				songHighscore = 'Milf';
		}

		#if !switch
		intendedScore = Highscore.getScore(songHighscore, curDifficulty);
		combo = Highscore.getCombo(songHighscore, curDifficulty);
		letter = Highscore.getLetter(songHighscore, curDifficulty);
		intendedaccuracy = Highscore.getAcc(songHighscore, curDifficulty);
		// lerpScore = 0;
		#end

		updateDiffCalc();
		diffText.text = 'DIFFICULTY: < ' + CoolUtil.difficultyFromInt(curDifficulty, songs[curSelected].songName == 'fin4le').toUpperCase() + ' >';

		/*#if PRELOAD_ALL
			if (songs[curSelected].songCharacter == "sm")
			{
				var data = songs[curSelected];
				trace("Loading " + data.path + "/" + data.sm.header.MUSIC);
				var bytes = File.getBytes(data.path + "/" + data.sm.header.MUSIC);
				var sound = new Sound();
				sound.loadCompressedDataFromByteArray(bytes.getData(), bytes.length);
				FlxG.sound.playMusic(sound);
			}
			else
			{
				FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0.7);
			}
			#end */
		/*var hmm;
			try
			{
				hmm = songData.get(songs[curSelected].songName)[curDifficulty];
				if (hmm != null)
				{
					Conductor.changeBPM(hmm.bpm);
					GameplayCustomizeState.freeplayBf = hmm.player1;
					GameplayCustomizeState.freeplayDad = hmm.player2;
					GameplayCustomizeState.freeplayGf = hmm.gfVersion;
					GameplayCustomizeState.freeplayNoteStyle = hmm.noteStyle;
					GameplayCustomizeState.freeplayStage = hmm.stage;
					GameplayCustomizeState.freeplaySong = hmm.songId;
					GameplayCustomizeState.freeplayWeek = songs[curSelected].week;
				}
			}
			catch (ex)
			{
		}*/

		if (openedPreview)
		{
			closeSubState();
			openSubState(new DiffOverview());
		}

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}

		if (songs[curSelected].songName == 'bi')
		{
			FlxTween.cancelTweensOf(bgHive);
			FlxTween.tween(bgHive, {alpha: 1}, 0.25, {
				ease: FlxEase.quadInOut,
				onComplete: function(tween:FlxTween)
				{
					bgHive.alpha = 1;
				}
			});
		}
		else
		{
			FlxTween.cancelTweensOf(bgHive);
			FlxTween.tween(bgHive, {alpha: 0}, 0.25, {
				ease: FlxEase.quadInOut,
				onComplete: function(tween:FlxTween)
				{
					bgHive.alpha = 0;
				}
			});
		}
	}
}

class FreeplaySongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	#if FEATURE_STEPMANIA
	public var sm:SMFile;
	public var path:String;
	#end
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var diffs = [];

	#if FEATURE_STEPMANIA
	public function new(song:String, week:Int, songCharacter:String, ?color:Int, ?sm:SMFile = null, ?path:String = "")
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.sm = sm;
		this.path = path;
	}
	#else
	public function new(song:String, week:Int, songCharacter:String, ?color:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
	}
	#end
}

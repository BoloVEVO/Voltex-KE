package;

import flixel.system.FlxSound;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;

	var curCharacter:String = '';

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	var curEmoteBox:String = '';

	var curEmoteChar:String = '';

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;

	var portraitSides:Array<FlxSprite> = [];

	var dropText:FlxText;
	var skipText:FlxText;

	var typingOver:Bool = false;

	public var finishThing:Void->Void;

	var portraitLeft:FlxSprite;
	var portraitRight:FlxSprite;

	var handSelect:FlxSprite;
	var bgFade:FlxSprite;

	var sound:FlxSound;

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>)
	{
		super();

		switch (PlayState.SONG.songId.toLowerCase())
		{
			case 'senpai':
				sound = new FlxSound().loadEmbedded(Paths.music('Lunchbox'), true);
				sound.volume = 0;
				FlxG.sound.list.add(sound);
				sound.fadeIn(1, 0, 0.8);
			case 'thorns':
				sound = new FlxSound().loadEmbedded(Paths.music('LunchboxScary'), true);
				sound.volume = 0;
				FlxG.sound.list.add(sound);
				sound.fadeIn(1, 0, 0.8);
		}

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		add(bgFade);

		new FlxTimer().start(0.83, function(tmr:FlxTimer)
		{
			switch (PlayState.storyWeek)
			{
				case 6:
					bgFade.alpha += (1 / 5) * 0.7;
					if (bgFade.alpha > 0.7)
						bgFade.alpha = 0.7;
				default:
					FlxTween.tween(bgFade, {alpha: 0.7}, 0.75, {ease: FlxEase.cubeOut});
			}
		}, 5);

		box = new FlxSprite(70, 370);

		var hasDialog = false;
		switch (PlayState.SONG.songId.toLowerCase())
		{
			case 'senpai':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-pixel');
				box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
				box.animation.addByIndices('normal', 'Text Box Appear', [4], "", 24);
				box.antialiasing = FlxG.save.data.antialiasing;
				box.setGraphicSize(Std.int(box.width * CoolUtil.daPixelZoom * 0.9));
				box.x = -20;
				box.y = -45;
			case 'roses':
				hasDialog = true;
				FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX'));

				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-senpaiMad');
				box.animation.addByPrefix('normalOpen', 'SENPAI ANGRY IMPACT SPEECH', 24, false);
				box.animation.addByIndices('normal', 'SENPAI ANGRY IMPACT SPEECH', [4], "", 24);
				box.setGraphicSize(Std.int(box.width * CoolUtil.daPixelZoom * 0.9));
				box.x = -20;
				box.y = -45;
			case 'thorns':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-evil');
				box.animation.addByPrefix('normalOpen', 'Spirit Textbox spawn', 24, false);
				box.animation.addByIndices('normal', 'Spirit Textbox spawn', [11], "", 24);
				box.setGraphicSize(Std.int(box.width * CoolUtil.daPixelZoom * 0.9));
				var face:FlxSprite = new FlxSprite(320, 170).loadGraphic(Paths.image('weeb/spiritFaceForward'));
				face.setGraphicSize(Std.int(face.width * 6));
				box.x = -20;
				box.y = -45;
				add(face);
			default:
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('speech_bubble', 'shared');
				box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
				box.animation.addByPrefix('normal', 'speech bubble normal', 24, false);
				box.animation.addByPrefix('MiddleOpen', 'Speech Bubble Middle Open', 24, false);
				box.animation.addByPrefix('middleNormal', 'speech bubble middle', 24, false);
				box.animation.addByPrefix('UpsetNormal', 'AHH speech bubble', 24, false);
				box.animation.addByPrefix('UpsetNormalMiddle', 'AHH Speech Bubble middle', 24, false);
				box.animation.addByPrefix('REEEopen', 'speech bubble loud open', 24, false);
				box.animation.addByPrefix('REEEmiddleOpen', 'speech bubble Middle loud open', 24, false);

				box.setGraphicSize(Std.int(box.width * 0.9));
				box.y = 375;
		}

		this.dialogueList = dialogueList;

		if (!hasDialog)
			return;

		portraitRight = new FlxSprite(785, 150);
		portraitRight.frames = Paths.getSparrowAtlas('dialogue_portraits/BF_Dialogue', 'shared');
		portraitRight.animation.addByPrefix('normalStatic', 'BF', 24, false);
		portraitRight.animation.addByPrefix('confusedStatic', 'BF CONFUSED', 24, false);
		portraitRight.animation.addByPrefix('confused', 'BF CONFUSED LOOP', 24, false);
		portraitRight.animation.addByPrefix('excitedStatic', 'BF EXCITED', 24, false);
		portraitRight.animation.addByPrefix('excited', 'BF EXCITED LOOP', 24, false);
		portraitRight.animation.addByPrefix('normal', 'BF LOOP', 24, false);
		portraitRight.animation.addByPrefix('angryStatic', 'BF PISSED', 24, false);
		portraitRight.animation.addByPrefix('angry', 'BF PISSED LOOP', 24, false);
		portraitRight.animation.addByPrefix('scaredStatic', 'BF SHOCK', 24, false);
		portraitRight.animation.addByPrefix('scared', 'BF SHOCK LOOP', 24, false);
		portraitRight.setGraphicSize(Std.int(portraitRight.width * 0.9));
		portraitRight.antialiasing = FlxG.save.data.antialiasing;
		portraitRight.scrollFactor.set();

		portraitRight.visible = false;
		switch (PlayState.SONG.songId.toLowerCase())
		{
			case 'senpai', 'roses', 'thorns':
				portraitLeft = new FlxSprite(-20, 40);
				portraitLeft.frames = Paths.getSparrowAtlas('weeb/senpaiPortrait');
				portraitLeft.animation.addByPrefix('enter', 'Senpai Portrait Enter', 24, false);
				portraitLeft.setGraphicSize(Std.int(portraitLeft.width * CoolUtil.daPixelZoom * 0.9));
				portraitLeft.updateHitbox();
				portraitLeft.scrollFactor.set();

				portraitLeft.visible = false;

				portraitRight = new FlxSprite(0, 40);
				portraitRight.frames = Paths.getSparrowAtlas('weeb/bfPortrait');
				portraitRight.animation.addByPrefix('enter', 'Boyfriend portrait enter', 24, false);
				portraitRight.setGraphicSize(Std.int(portraitRight.width * CoolUtil.daPixelZoom * 0.9));
				portraitRight.updateHitbox();
				portraitRight.scrollFactor.set();

				portraitRight.visible = false;
			case 'made-in-love', 'sayonara-planet-wars':
				portraitLeft = new FlxSprite(125, 200);
				portraitLeft.frames = Paths.getSparrowAtlas('dialogue_portraits/dialogue_tamaneko', 'shared');
				portraitLeft.animation.addByPrefix('angry', 'Tamaneko_dialogue_angry', 24, false);
				portraitLeft.animation.addByPrefix('normal', 'Tamaneko_dialogue_normal', 24, false);
				portraitLeft.animation.addByPrefix('excited', 'Tamaneko_dialogue_ready', 24, false);
				portraitLeft.setGraphicSize(Std.int(portraitLeft.width * 0.9));
				portraitRight.scrollFactor.set();
				portraitLeft.antialiasing = FlxG.save.data.antialiasing;
				portraitLeft.visible = false;
			case 'i':
				portraitLeft = new FlxSprite(50, -35);
				portraitLeft.frames = Paths.getSparrowAtlas('dialogue_portraits/dialogue_rasis', 'shared');
				portraitLeft.animation.addByPrefix('scared', 'Rasis_dialogue_surprised', 24, false);
				portraitLeft.animation.addByPrefix('normal', 'Rasis_dialogue_normal', 24, false);
				portraitLeft.animation.addByPrefix('excited', 'rasis_dialogue_ready', 24, false);
				portraitLeft.setGraphicSize(Std.int(portraitLeft.width * 0.9));
				portraitRight.scrollFactor.set();
				portraitLeft.antialiasing = FlxG.save.data.antialiasing;
				portraitLeft.visible = false;
		}

		/*add(portraitLeft);
			add(portraitRight); */

		portraitSides.push(portraitLeft);
		portraitSides.push(portraitRight);

		for (i in 0...portraitSides.length)
			add(portraitSides[i]);

		box.animation.play('normalOpen');
		box.updateHitbox();
		add(box);

		// box.screenCenter(X);
		// portraitLeft.screenCenter(X);
		skipText = new FlxText(FlxG.width - 300, 10, Std.int(FlxG.width * 0.6), "", 16);
		skipText.font = 'Pixel Arial 11 Bold';
		skipText.color = 0x000000;
		skipText.text = 'Press BACK to skip';
		add(skipText);
		handSelect = new FlxSprite(FlxG.width * 0.9, FlxG.height * 0.9).loadGraphic(Paths.image('weeb/pixelUI/hand_textbox'));
		add(handSelect);

		if (!talkingRight)
		{
			// box.flipX = true;
		}

		dropText = new FlxText(242, 502, Std.int(FlxG.width * 0.6), "", 32);
		dropText.font = 'Pixel Arial 11 Bold';
		dropText.color = 0xFFD89494;
		add(dropText);

		swagDialogue = new FlxTypeText(240, 500, Std.int(FlxG.width * 0.6), "", 32);
		swagDialogue.font = 'Pixel Arial 11 Bold';
		swagDialogue.color = 0xFF3F2021;

		switch (PlayState.SONG.songId.toLowerCase())
		{
			case 'senpai', 'roses', 'thorns':
				dropText.visible = true;
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
			default:
				handSelect.visible = false;
				swagDialogue.color = FlxColor.BLACK;
				dropText.visible = false;
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue'), 0.6)];
		}
		add(swagDialogue);

		dialogue = new Alphabet(0, 80, "", false, true);
		// dialogue.x = 90;
		// add(dialogue);
	}

	function swagDialogueCompleted():Void
	{
		typingOver = true;
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	override function update(elapsed:Float)
	{
		// HARD CODING CUZ IM STUPDI
		if (PlayState.SONG.songId.toLowerCase() == 'roses')
			portraitLeft.visible = false;
		if (PlayState.SONG.songId.toLowerCase() == 'thorns')
		{
			portraitLeft.visible = false;
			swagDialogue.color = FlxColor.WHITE;
			dropText.color = FlxColor.BLACK;
		}
		swagDialogue.completeCallback = swagDialogueCompleted;
		dropText.text = swagDialogue.text;
		// Custom Animation for Psych dialogue boxes
		if (box.animation.curAnim != null)
		{
			if ((box.animation.curAnim.finished || dialogueStarted) && !isEnding)
			{
				switch (curEmoteBox)
				{
					case 'upsetBox':
						box.animation.play('UpsetNormal');
						box.offset.set(50, 65);
					case 'normalBox':
						box.animation.play('normal');
						box.offset.set(10, 0);
					default:
						box.animation.play('normal');
						box.offset.set(10, 0);
				}
				dialogueOpened = true;
			}
		}
		// Custom Animations for Psych dialogue characters.
		for (i in 0...portraitSides.length)
		{
			if (!typingOver)
			{
				switch (curEmoteChar)
				{
					default:
						portraitSides[i].animation.play('normal');
					case 'normal':
						portraitSides[i].animation.play('normal');
					case 'angry':
						portraitSides[i].animation.play('angry');
					case 'excited':
						portraitSides[i].animation.play('excited');
					case 'confused':
						portraitSides[i].animation.play('confused');
					case 'scared':
						portraitSides[i].animation.play('scared');
				}
			}
		}

		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}

		if (PlayerSettings.player1.controls.BACK && isEnding != true)
		{
			remove(dialogue);
			isEnding = true;
			switch (PlayState.SONG.songId.toLowerCase())
			{
				case "senpai" | "thorns":
					sound.fadeOut(2.2, 0);
				case "roses":
					trace("roses");
				default:
					trace("other song");
			}
			new FlxTimer().start(0.2, function(tmr:FlxTimer)
			{
				switch (PlayState.storyWeek)
				{
					case 6:
						box.alpha -= 1 / 5;
						bgFade.alpha -= 1 / 5 * 0.7;
						portraitLeft.visible = false;
						portraitRight.visible = false;
						swagDialogue.alpha -= 1 / 5;
						dropText.alpha = swagDialogue.alpha;
					default:
						box.animation.play('normalOpen', false, true);
						new FlxTimer().start(0.15, function(tmr:FlxTimer)
						{
							box.visible = false;
						});
						portraitRight.visible = false;
						portraitLeft.visible = false;
						swagDialogue.visible = false;
						FlxTween.tween(bgFade, {alpha: 0}, 0.75, {ease: FlxEase.cubeOut});
						FlxTween.tween(swagDialogue, {alpha: 0}, 0.75, {ease: FlxEase.cubeOut});
				}
			}, 5);

			new FlxTimer().start(1.2, function(tmr:FlxTimer)
			{
				finishThing();
				kill();
				destroy();
			});
		}
		if (PlayerSettings.player1.controls.ACCEPT && dialogueStarted == true)
		{
			remove(dialogue);

			switch (PlayState.SONG.songId.toLowerCase())
			{
				case 'senpai', 'roses', 'thorns':
					FlxG.sound.play(Paths.sound('clickText'), 0.8);
				default:
					FlxG.sound.play(Paths.sound('dialogueClose'), 0.8);
			}

			// DUMB FUCK CONDITION BTW DON'T MIND ME. IT'S THE WORST WAY TO CHANGE CHARACTER SPRITES.
			if (PlayState.SONG.songId.toLowerCase() == 'sayonara-planet-wars')
			{
				if (dialogueList[0] == 'Nya...')
				{
					Debug.logInfo('Giving Tamaneko permission to say the N-word.');
					portraitLeft.x = 135;
					portraitLeft.y = 220;
					portraitLeft.frames = Paths.getSparrowAtlas('dialogue_portraits/dialogue_darktamaneko', 'shared');
					portraitLeft.animation.addByPrefix('angry', 'Tamaneko_dialogue_angry', 24, false);
					portraitLeft.animation.addByPrefix('normal', 'Tamaneko_dialogue_normal', 24, false);
					portraitLeft.animation.addByPrefix('excited', 'Tamaneko_dialogue_ready', 24, false);
					portraitLeft.updateHitbox();
				}
			}

			if (PlayState.SONG.songId.toLowerCase() == 'i' && PlayState.instance.endingSong)
			{
				if (dialogueList[0] == 'Wow,you are really talented!')
				{
					Debug.logInfo('Baka cat fucking around the dialogues ENABLED.');
					portraitLeft.x = 135;
					portraitLeft.y = 220;
					portraitLeft.frames = Paths.getSparrowAtlas('dialogue_portraits/dialogue_tamaneko', 'shared');
					portraitLeft.animation.addByPrefix('angry', 'Tamaneko_dialogue_angry', 24, false);
					portraitLeft.animation.addByPrefix('normal', 'Tamaneko_dialogue_normal', 24, false);
					portraitLeft.animation.addByPrefix('excited', 'Tamaneko_dialogue_ready', 24, false);
					portraitLeft.updateHitbox();
				}
				else if (dialogueList[0] == 'ENCORE!!!')
				{
					portraitLeft.x = 70;
					portraitLeft.y = -10;
					portraitLeft.frames = Paths.getSparrowAtlas('dialogue_portraits/dialogue_rasis', 'shared');
					portraitLeft.animation.addByPrefix('scared', 'Rasis_dialogue_surprised', 24, false);
					portraitLeft.animation.addByPrefix('normal', 'Rasis_dialogue_normal', 24, false);
					portraitLeft.animation.addByPrefix('excited', 'rasis_dialogue_ready', 24, false);
					portraitLeft.updateHitbox();
				}
			}

			if (dialogueList[1] == null && dialogueList[0] != null)
			{
				switch (PlayState.SONG.songId.toLowerCase())
				{
					case 'senpai', 'roses', 'thorns':

					default:
						box.animation.play('normalOpen', false, true);
						new FlxTimer().start(0.15, function(tmr:FlxTimer)
						{
							box.visible = false;
						});
				}

				if (!isEnding)
				{
					isEnding = true;
					switch (PlayState.storyWeek)
					{
						case 6:
							if (PlayState.SONG.songId.toLowerCase() == 'senpai' || PlayState.SONG.songId.toLowerCase() == 'thorns')
								sound.fadeOut(2.2, 0);
							new FlxTimer().start(0.2, function(tmr:FlxTimer)
							{
								box.alpha -= 1 / 5;
								bgFade.alpha -= 1 / 5 * 0.7;

								swagDialogue.alpha -= 1 / 5;
								dropText.alpha = swagDialogue.alpha;
							}, 5);
						default:
							swagDialogue.visible = false;
							FlxTween.tween(bgFade, {alpha: 0}, 0.75, {ease: FlxEase.cubeOut});
							FlxTween.tween(swagDialogue, {alpha: 0}, 0.75, {ease: FlxEase.cubeOut});
					}
					portraitLeft.visible = false;
					portraitRight.visible = false;
					new FlxTimer().start(1.2, function(tmr:FlxTimer)
					{
						finishThing();
						kill();
						destroy();
					});
				}
			}
			else
			{
				dialogueList.remove(dialogueList[0]);
				startDialogue();
				typingOver = false;
			}
		}

		super.update(elapsed);
	}

	var isEnding:Bool = false;

	function startDialogue():Void
	{
		cleanDialog();
		// var theDialog:Alphabet = new Alphabet(0, 70, dialogueList[0], false, true);
		// dialogue = theDialog;
		// add(theDialog);

		// swagDialogue.text = ;
		swagDialogue.resetText(dialogueList[0]);
		swagDialogue.start(0.06, true);

		switch (curCharacter)
		{
			case 'dad':
				portraitRight.visible = false;
				if (!portraitLeft.visible)
				{
					portraitLeft.visible = true;
					// portraitLeft.animation.play('enter');
				}

				box.flipX = true;
			case 'bf':
				portraitLeft.visible = false;
				if (!portraitRight.visible)
				{
					portraitRight.visible = true;
					// portraitRight.animation.play('enter');
				}
				box.flipX = false;
		}
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		curCharacter = splitName[1];
		curEmoteBox = splitName[2];
		curEmoteChar = splitName[3];
		dialogueList[0] = dialogueList[0].substr(splitName[1].length + splitName[2].length + splitName[3].length + 4).trim();
	}
}

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

class LazyCreditState extends MusicBeatState
{
	var menuBG:FlxSprite;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
		menuBG = new FlxSprite().loadGraphic(Paths.image("Lazy_Credits_Screen")); // Kinda Lazy make a CreditState lol.
		menuBG.setGraphicSize(Std.int(menuBG.width));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = FlxG.save.data.antialiasing;
		add(menuBG);
		super.create();
	}

	override function update(elapsed)
	{
		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;
		if (pressedEnter)
		{
			if (menuBG.graphic != Paths.image("Lazy_Credits_Screen"))
			{
				MusicBeatState.switchState(new MainMenuState());
			}
			else
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 1);
				menuBG.loadGraphic(Paths.image("KadeReminder"));
			}
		}
		super.update(elapsed);
	}
}

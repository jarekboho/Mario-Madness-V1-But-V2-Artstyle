package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxPoint;
	var camFollowPos:FlxObject;
	var updateCamera:Bool = false;

	var stageSuffix:String = "";

	var lePlayState:PlayState;

	public static var characterName:String = 'bf';
	public static var deathSoundName:String = 'fnf_loss_sfx';
	public static var loopSoundName:String = 'gameOver';
	public static var endSoundName:String = 'gameOverEnd';

	public static function resetVariables() {
		characterName = 'bf';
		deathSoundName = 'fnf_loss_sfx';
		loopSoundName = 'gameOver';
		endSoundName = 'gameOverEnd';
	}

	public function new(x:Float, y:Float, camX:Float, camY:Float, state:PlayState)
	{
		lePlayState = state;
		state.setOnLuas('inGameOver', true);
		super();

		Conductor.songPosition = 0;

		bf = new Boyfriend(x, y, characterName);
		if(characterName == 'bfexenewdeath')
		{
		bf.x -= 175;
		bf.y -= 260;
		}
		add(bf);

		camFollow = new FlxPoint(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y);

		FlxG.sound.play(Paths.sound(deathSoundName));
		Conductor.changeBPM(100);
		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');

		var exclude:Array<Int> = [];

		camFollowPos = new FlxObject(0, 0, 1, 1);
		camFollowPos.setPosition(FlxG.camera.scroll.x + (FlxG.camera.width / 2), FlxG.camera.scroll.y + (FlxG.camera.height / 2));
		add(camFollowPos);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		lePlayState.callOnLuas('onUpdate', [elapsed]);
		if(updateCamera) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 0.6, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
		}

		if (controls.ACCEPT && PlayState.curStage != 'racing')
		{
			endBullshit();
		}

		if (controls.BACK)
		{
			FlxG.updateFramerate = PlayState.fpsthing;
			FlxG.drawFramerate = PlayState.fpsthing; 
			ClientPrefs.framerate = PlayState.fpsthing;
			ClientPrefs.saveSettings();
			FlxG.sound.music.stop();
			PlayState.deathCounter = 0;
			PlayState.seenCutscene = false;

			if(PlayState.isStoryMode) {
				MusicBeatState.switchState(new StoryMenuState());
			} else if (PlayState.isWarp) {
				MusicBeatState.switchState(new WarpState());
			}else{
				MusicBeatState.switchState(new CustomFreeplayState());
			}

			//FlxG.sound.playMusic(Paths.music('freakyMenu'));
			lePlayState.callOnLuas('onGameOverConfirm', [false]);
		}

		if (bf.animation.curAnim.name == 'firstDeath')
		{
			if (PlayState.curStage == 'warioworld')
				{
					var pibewario:FlxSprite = new FlxSprite().loadGraphic(Paths.image('modstuff/wariodeath'));
					pibewario.updateHitbox();
					pibewario.screenCenter();
					add(pibewario);
				}
			else if (PlayState.curStage == 'racing'){
				var blackthing = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
					blackthing.setGraphicSize(Std.int(blackthing.width * 10));
					add(blackthing);
					
					new FlxTimer().start(0.7, function(tmr:FlxTimer)
						{
							FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
							{
								MusicBeatState.resetState();
							});
						});
			}
				
			else
			{
				if(bf.animation.curAnim.curFrame == 12)
					{
						FlxG.camera.follow(camFollowPos, LOCKON, 1);
						updateCamera = true;
					}
		
					if (bf.animation.curAnim.finished)
					{
						coolStartDeath();
						bf.startedDeath = true;
					}
			}
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
		lePlayState.callOnLuas('onUpdatePost', [elapsed]);
	}

	override function beatHit()
	{
		super.beatHit();

		//FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function coolStartDeath(?volume:Float = 1):Void
	{
		if(PlayState.curStage != 'warioworld' && PlayState.curStage != 'racing'){
			FlxG.sound.playMusic(Paths.music(loopSoundName), volume);
		}
		
	}

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music(endSoundName));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					MusicBeatState.resetState();
				});
			});
			lePlayState.callOnLuas('onGameOverConfirm', [true]);
		}
	}
}

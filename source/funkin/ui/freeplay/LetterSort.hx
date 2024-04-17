package funkin.ui.freeplay;

import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import funkin.graphics.adobeanimate.FlxAtlasSprite;

class LetterSort extends FlxTypedSpriteGroup<FlxSprite>
{
  public var letters:Array<FreeplayLetter> = [];

  // starts at 2, cuz that's the middle letter on start (accounting for fav and #, it should begin at ALL filter)
  var curSelection:Int = 2;

  public var changeSelectionCallback:String->Void;

  var leftArrow:FlxSprite;
  var rightArrow:FlxSprite;
  var grpSeperators:Array<FlxSprite> = [];

  public var inputEnabled:Bool = true;

  public function new(x, y)
  {
    super(x, y);

    leftArrow = new FlxSprite(-20, 15).loadGraphic(Paths.image("freeplay/miniArrow"));
    // leftArrow.animation.play("arrow");
    leftArrow.flipX = true;
    add(leftArrow);

    for (i in 0...5)
    {
      var letter:FreeplayLetter = new FreeplayLetter(i * 80, 0, i);
      letter.x += 50;
      letter.y += 50;
      letter.ogY = y;
      // letter.visible = false;
      add(letter);

      letters.push(letter);

      if (i != 2) letter.scale.x = letter.scale.y = 0.8;

      var darkness:Float = Math.abs(i - 2) / 6;

      letter.color = letter.color.getDarkened(darkness);

      // don't put the last seperator
      if (i == 4) continue;

      var sep:FlxSprite = new FlxSprite((i * 80) + 60, 20).loadGraphic(Paths.image("freeplay/seperator"));
      // sep.animation.play("seperator");
      sep.color = letter.color.getDarkened(darkness);
      add(sep);

      grpSeperators.push(sep);
    }

    rightArrow = new FlxSprite(380, 15).loadGraphic(Paths.image("freeplay/miniArrow"));

    // rightArrow.animation.play("arrow");
    add(rightArrow);

    changeSelection(0);
  }

  override function update(elapsed:Float):Void
  {
    super.update(elapsed);

    if (inputEnabled)
    {
      if (FlxG.keys.justPressed.E) changeSelection(1);
      if (FlxG.keys.justPressed.Q) changeSelection(-1);
    }
  }

  public function changeSelection(diff:Int = 0):Void
  {
    var ezTimer:Int->FlxSprite->Float->Void = function(frameNum:Int, spr:FlxSprite, offsetNum:Float) {
      new FlxTimer().start(frameNum / 24, function(_) {
        spr.offset.x = offsetNum;
      });
    };

    var positions:Array<Float> = [-10, -22, 2, 0];

    if (diff < 0)
    {
      for (sep in grpSeperators)
      {
        ezTimer(0, sep, positions[0]);
        ezTimer(1, sep, positions[1]);
        ezTimer(2, sep, positions[2]);
        ezTimer(3, sep, positions[3]);
      }

      for (index => letter in letters)
      {
        letter.offset.x = positions[0];

        new FlxTimer().start(1 / 24, function(_) {
          letter.offset.x = positions[1];
          if (index == 0) letter.visible = false;
        });

        new FlxTimer().start(2 / 24, function(_) {
          letter.offset.x = positions[2];
          if (index == 0.) letter.visible = true;
        });

        if (index == 2)
        {
          ezTimer(3, letter, 0);
          // letter.offset.x = 0;
          continue;
        }

        ezTimer(3, letter, positions[3]);
      }

      leftArrow.offset.x = 3;
      new FlxTimer().start(2 / 24, function(_) {
        leftArrow.offset.x = 0;
      });
    }
    else if (diff > 0)
    {
      for (sep in grpSeperators)
      {
        ezTimer(0, sep, -positions[0]);
        ezTimer(1, sep, -positions[1]);
        ezTimer(2, sep, -positions[2]);
        ezTimer(3, sep, -positions[3]);
      }
      // same timing and functions and shit as the left one... except to the right!!

      for (index => letter in letters)
      {
        letter.offset.x = -positions[0];

        new FlxTimer().start(1 / 24, function(_) {
          letter.offset.x = -positions[1];
          if (index == 0) letter.visible = false;
        });

        new FlxTimer().start(2 / 24, function(_) {
          letter.offset.x = -positions[2];
          if (index == 0) letter.visible = true;
        });

        if (index == 2)
        {
          ezTimer(3, letter, 0);
          // letter.offset.x = 0;
          continue;
        }

        ezTimer(3, letter, -positions[3]);
      }

      rightArrow.offset.x = -3;
      new FlxTimer().start(2 / 24, function(_) {
        rightArrow.offset.x = 0;
      });
    }

    curSelection += diff;
    if (curSelection < 0) curSelection = letters[0].regexLetters.length - 1;
    if (curSelection >= letters[0].regexLetters.length) curSelection = 0;

    for (letter in letters)
      letter.changeLetter(diff, curSelection);

    if (changeSelectionCallback != null) changeSelectionCallback(letters[2].regexLetters[letters[2].curLetter]); // bullshit and long lol!
  }
}

class FreeplayLetter extends FlxAtlasSprite
{
  /**
   * A preformatted array of letter strings, for use when doing regex
   * ex: ['A-B', 'C-D', 'E-H', 'I-L' ...]
   */
  public var regexLetters:Array<String> = [];

  /**
   * A preformatted array of the letters, for use when accessing symbol animation info
   * ex: ['AB', 'CD', 'EH', 'IL' ...]
   */
  public var animLetters:Array<String> = [];

  /**
   * The current letter in the regexLetters array this FreeplayLetter is on
   */
  public var curLetter:Int = 0;

  public var ogY:Float = 0;

  public function new(x:Float, y:Float, ?letterInd:Int)
  {
    super(x, y, Paths.animateAtlas("freeplay/sortedLetters"));

    // this is used for the regex
    // /^[OR].*/gi doesn't work for showing the song Pico, so now it's
    // /^[O-R].*/gi ant it works for displaying Pico
    // https://regex101.com/r/bWFPfS/1
    // we split by underscores, simply for nice lil convinience
    var alphabet:String = 'A-B_C-D_E-H_I-L_M-N_O-R_S_T_U-Z';
    regexLetters = alphabet.split('_');
    regexLetters.insert(0, 'ALL');
    regexLetters.insert(0, 'fav');
    regexLetters.insert(0, '#');

    // the symbols from flash don't have dashes, so we clean this up for use with animations
    // (we don't need to re-export, rule of thumb is to accomodate files named in flash from dave
    //    until we get him programming classes (and since i cant find the .fla file....))
    animLetters = regexLetters.map(animLetter -> animLetter.replace('-', ''));

    if (letterInd != null)
    {
      this.anim.play(animLetters[letterInd] + " move");
      this.anim.pause();
      curLetter = letterInd;
    }
  }

  public function changeLetter(diff:Int = 0, ?curSelection:Int):Void
  {
    curLetter += diff;

    if (curLetter < 0) curLetter = regexLetters.length - 1;
    if (curLetter >= regexLetters.length) curLetter = 0;

    var animName:String = animLetters[curLetter] + " move";

    switch (animLetters[curLetter])
    {
      case "IL":
        animName = "IL move";
      case "s":
        animName = "S move";
      case "t":
        animName = "T move";
    }

    this.anim.play(animName);
    if (curSelection != curLetter)
    {
      this.anim.pause();
    }
    // updateHitbox();
  }
}

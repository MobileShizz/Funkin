package funkin;

import flixel.FlxG;
import flixel.FlxState;
import funkin.Conductor;
import funkin.play.song.SongData.SongTimeChange;
import funkin.util.Constants;
import massive.munit.Assert;

@:access(funkin.Conductor)
class ConductorTest extends FunkinTest
{
  var conductorState:ConductorState;

  @Before
  function before()
  {
    resetGame();

    // The ConductorState will advance the conductor when step() is called.
    FlxG.switchState(conductorState = new ConductorState());

    Conductor.reset();
  }

  @Test
  function testDefaultValues():Void
  {
    // NOTE: Expected value comes first.

    Assert.areEqual([], Conductor.timeChanges);
    Assert.areEqual(null, Conductor.currentTimeChange);

    Assert.areEqual(0, Conductor.songPosition);
    Assert.areEqual(Constants.DEFAULT_BPM, Conductor.bpm);
    Assert.areEqual(null, Conductor.bpmOverride);

    Assert.areEqual(600, Conductor.beatLengthMs);

    Assert.areEqual(4, Conductor.timeSignatureNumerator);
    Assert.areEqual(4, Conductor.timeSignatureDenominator);

    Assert.areEqual(0, Conductor.currentBeat);
    Assert.areEqual(0, Conductor.currentStep);
    Assert.areEqual(0.0, Conductor.currentStepTime);

    Assert.areEqual(150, Conductor.stepLengthMs);
  }

  /**
   * Tests implementation of `update()`, and how it affects
   * `currentBeat`, `currentStep`, `currentStepTime`, and the `beatHit` and `stepHit` signals.
   */
  @Test
  function testUpdate():Void
  {
    Assert.areEqual(0, Conductor.songPosition);

    step(); // 1

    var BPM_100_STEP_TIME = 1 / 9;

    FunkinAssert.areNear(FunkinTest.MS_PER_STEP * 1, Conductor.songPosition);
    Assert.areEqual(0, Conductor.currentBeat);
    Assert.areEqual(0, Conductor.currentStep);
    FunkinAssert.areNear(1 / 9, Conductor.currentStepTime);

    step(7); // 8

    FunkinAssert.areNear(FunkinTest.MS_PER_STEP * 8, Conductor.songPosition);
    Assert.areEqual(0, Conductor.currentBeat);
    Assert.areEqual(0, Conductor.currentStep);
    FunkinAssert.areNear(8 / 9, Conductor.currentStepTime);

    Assert.areEqual(0, conductorState.beatsHit);
    Assert.areEqual(0, conductorState.stepsHit);

    step(); // 9

    Assert.areEqual(0, conductorState.beatsHit);
    Assert.areEqual(1, conductorState.stepsHit);
    conductorState.beatsHit = 0;
    conductorState.stepsHit = 0;

    FunkinAssert.areNear(FunkinTest.MS_PER_STEP * 9, Conductor.songPosition);
    Assert.areEqual(0, Conductor.currentBeat);
    Assert.areEqual(1, Conductor.currentStep);
    FunkinAssert.areNear(1.0, Conductor.currentStepTime);

    step(35 - 9); // 35

    Assert.areEqual(0, conductorState.beatsHit);
    Assert.areEqual(2, conductorState.stepsHit);
    conductorState.beatsHit = 0;
    conductorState.stepsHit = 0;

    FunkinAssert.areNear(FunkinTest.MS_PER_STEP * 35, Conductor.songPosition);
    Assert.areEqual(0, Conductor.currentBeat);
    Assert.areEqual(3, Conductor.currentStep);
    FunkinAssert.areNear(3.0 + 8 / 9, Conductor.currentStepTime);

    step(); // 36

    Assert.areEqual(1, conductorState.beatsHit);
    Assert.areEqual(1, conductorState.stepsHit);
    conductorState.beatsHit = 0;
    conductorState.stepsHit = 0;

    FunkinAssert.areNear(FunkinTest.MS_PER_STEP * 36, Conductor.songPosition);
    Assert.areEqual(1, Conductor.currentBeat);
    Assert.areEqual(4, Conductor.currentStep);
    FunkinAssert.areNear(4.0, Conductor.currentStepTime);

    step(50 - 36); // 50

    FunkinAssert.areNear(FunkinTest.MS_PER_STEP * 50, Conductor.songPosition);
    Assert.areEqual(1, Conductor.currentBeat);
    Assert.areEqual(5, Conductor.currentStep);
    FunkinAssert.areNear(5.555555, Conductor.currentStepTime);

    step(49); // 99

    FunkinAssert.areNear(FunkinTest.MS_PER_STEP * 99, Conductor.songPosition);
    Assert.areEqual(2, Conductor.currentBeat);
    Assert.areEqual(11, Conductor.currentStep);
    FunkinAssert.areNear(11.0, Conductor.currentStepTime);

    step(1); // 100

    FunkinAssert.areNear(FunkinTest.MS_PER_STEP * 100, Conductor.songPosition);
    Assert.areEqual(2, Conductor.currentBeat);
    Assert.areEqual(11, Conductor.currentStep);
    FunkinAssert.areNear(11.111111, Conductor.currentStepTime);
  }

  @Test
  function testUpdateForcedBPM():Void
  {
    Conductor.forceBPM(60);

    Assert.areEqual(0, Conductor.songPosition);

    // 60 beats per minute = 1 beat per second
    // 1 beat per second = 1/60 beats per frame = 4/60 steps per frame
    step(); // Advances time 1/60 of 1 second.

    FunkinAssert.areNear(FunkinTest.MS_PER_STEP * 1, Conductor.songPosition);
    Assert.areEqual(0, Conductor.currentBeat);
    Assert.areEqual(0, Conductor.currentStep);
    FunkinAssert.areNear(4 / 60, Conductor.currentStepTime); // 1/60 of 1 beat = 4/60 of 1 step

    step(14 - 1); // 14

    FunkinAssert.areNear(FunkinTest.MS_PER_STEP * 14, Conductor.songPosition);
    Assert.areEqual(0, Conductor.currentBeat);
    Assert.areEqual(0, Conductor.currentStep);
    FunkinAssert.areNear(1.0 - 4 / 60, Conductor.currentStepTime); // 1/60 of 1 beat = 4/60 of 1 step

    step(); // 15

    FunkinAssert.areNear(FunkinTest.MS_PER_STEP * 15, Conductor.songPosition);
    Assert.areEqual(0, Conductor.currentBeat);
    Assert.areEqual(1, Conductor.currentStep);
    FunkinAssert.areNear(1.0, Conductor.currentStepTime); // 1/60 of 1 beat = 4/60 of 1 step

    step(45 - 1); // 59

    FunkinAssert.areNear(FunkinTest.MS_PER_STEP * 59, Conductor.songPosition);
    Assert.areEqual(0, Conductor.currentBeat);
    Assert.areEqual(3, Conductor.currentStep);
    FunkinAssert.areNear(4.0 - 4 / 60, Conductor.currentStepTime);

    step(); // 60

    FunkinAssert.areNear(FunkinTest.MS_PER_STEP * 60, Conductor.songPosition);
    Assert.areEqual(1, Conductor.currentBeat);
    Assert.areEqual(4, Conductor.currentStep);
    FunkinAssert.areNear(4.0, Conductor.currentStepTime);

    step(); // 61

    FunkinAssert.areNear(FunkinTest.MS_PER_STEP * 61, Conductor.songPosition);
    Assert.areEqual(1, Conductor.currentBeat);
    Assert.areEqual(4, Conductor.currentStep);
    FunkinAssert.areNear(4.0 + 4 / 60, Conductor.currentStepTime);
  }

  @Test
  function testSingleTimeChange():Void
  {
    // Start the song with a BPM of 120.
    var songTimeChanges:Array<SongTimeChange> = [
      {
        t: 0,
        b: 0,
        bpm: 120,
        n: 4,
        d: 4,
        bt: [4, 4, 4, 4]
      }, // 120 bpm starting 0 sec/0 beats
    ];
    Conductor.mapTimeChanges(songTimeChanges);

    // All should be at 0.
    FunkinAssert.areNear(0, Conductor.songPosition);
    Assert.areEqual(0, Conductor.currentBeat);
    Assert.areEqual(0, Conductor.currentStep);
    FunkinAssert.areNear(0.0, Conductor.currentStepTime); // 2/120 of 1 beat = 8/120 of 1 step

    // 120 beats per minute = 2 beat per second
    // 2 beat per second = 2/60 beats per frame = 16/120 steps per frame
    step(); // Advances time 1/60 of 1 second.

    FunkinAssert.areNear(FunkinTest.MS_PER_STEP * 1, Conductor.songPosition);
    Assert.areEqual(0, Conductor.currentBeat);
    Assert.areEqual(0, Conductor.currentStep);
    FunkinAssert.areNear(16 / 120, Conductor.currentStepTime); // 2/120 of 1 beat = 8/120 of 1 step

    step(15 - 1); // 15

    FunkinAssert.areNear(FunkinTest.MS_PER_STEP * 15, Conductor.songPosition);
    Assert.areEqual(0, Conductor.currentBeat);
    Assert.areEqual(2, Conductor.currentStep);
    FunkinAssert.areNear(2.0, Conductor.currentStepTime); // 2/60 of 1 beat = 8/60 of 1 step

    step(45 - 1); // 59

    FunkinAssert.areNear(FunkinTest.MS_PER_STEP * 59, Conductor.songPosition);
    Assert.areEqual(1, Conductor.currentBeat);
    Assert.areEqual(7, Conductor.currentStep);
    FunkinAssert.areNear(7.0 + 104 / 120, Conductor.currentStepTime);

    step(); // 60

    FunkinAssert.areNear(FunkinTest.MS_PER_STEP * 60, Conductor.songPosition);
    Assert.areEqual(2, Conductor.currentBeat);
    Assert.areEqual(8, Conductor.currentStep);
    FunkinAssert.areNear(8.0, Conductor.currentStepTime);

    step(); // 61

    FunkinAssert.areNear(FunkinTest.MS_PER_STEP * 61, Conductor.songPosition);
    Assert.areEqual(2, Conductor.currentBeat);
    Assert.areEqual(8, Conductor.currentStep);
    FunkinAssert.areNear(8.0 + 8 / 60, Conductor.currentStepTime);
  }

  @Test
  function testDoubleTimeChange():Void
  {
    // Start the song with a BPM of 120.
    var songTimeChanges:Array<SongTimeChange> = [
      {
        t: 0,
        b: 0,
        bpm: 120,
        n: 4,
        d: 4,
        bt: [4, 4, 4, 4]
      }, // 120 bpm starting 0 sec/0 beats
      {
        t: 3000,
        b: 6,
        bpm: 90,
        n: 4,
        d: 4,
        bt: [4, 4, 4, 4]
      } // 90 bpm starting 3 sec/6 beats
    ];
    Conductor.mapTimeChanges(songTimeChanges);

    // All should be at 0.
    FunkinAssert.areNear(0, Conductor.songPosition);
    Assert.areEqual(0, Conductor.currentBeat);
    Assert.areEqual(0, Conductor.currentStep);
    FunkinAssert.areNear(0.0, Conductor.currentStepTime); // 2/120 of 1 beat = 8/120 of 1 step

    // 120 beats per minute = 2 beat per second
    // 2 beat per second = 2/60 beats per frame = 16/120 steps per frame
    step(); // Advances time 1/60 of 1 second.

    FunkinAssert.areNear(FunkinTest.MS_PER_STEP * 1, Conductor.songPosition);
    Assert.areEqual(0, Conductor.currentBeat);
    Assert.areEqual(0, Conductor.currentStep);
    FunkinAssert.areNear(16 / 120, Conductor.currentStepTime); // 4/120 of 1 beat = 16/120 of 1 step

    step(60 - 1 - 1); // 59

    FunkinAssert.areNear(FunkinTest.MS_PER_STEP * 59, Conductor.songPosition);
    Assert.areEqual(1, Conductor.currentBeat);
    Assert.areEqual(7, Conductor.currentStep);
    FunkinAssert.areNear(7.0 + 104 / 120, Conductor.currentStepTime);

    step(); // 60

    FunkinAssert.areNear(FunkinTest.MS_PER_STEP * 60, Conductor.songPosition);
    Assert.areEqual(2, Conductor.currentBeat);
    Assert.areEqual(8, Conductor.currentStep);
    FunkinAssert.areNear(8.0, Conductor.currentStepTime);

    step(); // 61

    FunkinAssert.areNear(FunkinTest.MS_PER_STEP * 61, Conductor.songPosition);
    Assert.areEqual(2, Conductor.currentBeat);
    Assert.areEqual(8, Conductor.currentStep);
    FunkinAssert.areNear(8.0 + 8 / 60, Conductor.currentStepTime);

    step(179 - 61); // 179

    FunkinAssert.areNear(FunkinTest.MS_PER_STEP * 179, Conductor.songPosition);
    Assert.areEqual(5, Conductor.currentBeat);
    Assert.areEqual(23, Conductor.currentStep);
    FunkinAssert.areNear(23.0 + 52 / 60, Conductor.currentStepTime);

    step(); // 180 (3 seconds)

    FunkinAssert.areNear(FunkinTest.MS_PER_STEP * 180, Conductor.songPosition);
    Assert.areEqual(6, Conductor.currentBeat);
    Assert.areEqual(24, Conductor.currentStep);
    FunkinAssert.areNear(24.0, Conductor.currentStepTime);

    step(); // 181 (3 + 1/60 seconds)
    // BPM has switched to 90!
    // 90 beats per minute = 1.5 beat per second
    // 1.5 beat per second = 1.5/60 beats per frame = 3/120 beats per frame
    // = 12/120 steps per frame

    FunkinAssert.areNear(FunkinTest.MS_PER_STEP * 181, Conductor.songPosition);
    Assert.areEqual(6, Conductor.currentBeat);
    Assert.areEqual(24, Conductor.currentStep);
    FunkinAssert.areNear(24.0 + 12 / 120, Conductor.currentStepTime);

    step(59); // 240 (4 seconds)

    FunkinAssert.areNear(FunkinTest.MS_PER_STEP * 240, Conductor.songPosition);
    Assert.areEqual(7, Conductor.currentBeat);
    Assert.areEqual(30, Conductor.currentStep);
    FunkinAssert.areNear(30.0, Conductor.currentStepTime);

    step(); // 241 (4 + 1/60 seconds)

    FunkinAssert.areNear(FunkinTest.MS_PER_STEP * 241, Conductor.songPosition);
    Assert.areEqual(7, Conductor.currentBeat);
    Assert.areEqual(30, Conductor.currentStep);
    FunkinAssert.areNear(30.0 + 12 / 120, Conductor.currentStepTime);
  }

  @Test
  function testTripleTimeChange():Void
  {
    // Start the song with a BPM of 120, then move to 90, then move to 180.
    var songTimeChanges:Array<SongTimeChange> = [
      {
        t: 0,
        b: null,
        bpm: 120,
        n: 4,
        d: 4,
        bt: [4, 4, 4, 4]
      }, // 120 bpm starting 0 sec/0 beats
      {
        t: 3000,
        b: null,
        bpm: 90,
        n: 4,
        d: 4,
        bt: [4, 4, 4, 4]
      }, // 90 bpm starting 3 sec/6 beats
      {
        t: 6000,
        b: null,
        bpm: 180,
        n: 4,
        d: 4,
        bt: [4, 4, 4, 4]
      } // 90 bpm starting 3 sec/6 beats
    ];
    Conductor.mapTimeChanges(songTimeChanges);

    // Verify time changes.
    Assert.areEqual(3, Conductor.timeChanges.length);
    FunkinAssert.areNear(0, Conductor.timeChanges[0].beatTime);
    FunkinAssert.areNear(6, Conductor.timeChanges[1].beatTime);
    FunkinAssert.areNear(10.5, Conductor.timeChanges[2].beatTime);

    // All should be at 0.
    FunkinAssert.areNear(0, Conductor.songPosition);
    Assert.areEqual(0, Conductor.currentBeat);
    Assert.areEqual(0, Conductor.currentStep);
    FunkinAssert.areNear(0.0, Conductor.currentStepTime); // 2/120 of 1 beat = 8/120 of 1 step

    // 120 beats per minute = 2 beat per second
    // 2 beat per second = 2/60 beats per frame = 16/120 steps per frame
    step(); // Advances time 1/60 of 1 second.

    FunkinAssert.areNear(FunkinTest.MS_PER_STEP * 1, Conductor.songPosition);
    Assert.areEqual(0, Conductor.currentBeat);
    Assert.areEqual(0, Conductor.currentStep);
    FunkinAssert.areNear(16 / 120, Conductor.currentStepTime); // 4/120 of 1 beat = 16/120 of 1 step

    step(60 - 1 - 1); // 59

    FunkinAssert.areNear(FunkinTest.MS_PER_STEP * 59, Conductor.songPosition);
    Assert.areEqual(1, Conductor.currentBeat);
    Assert.areEqual(7, Conductor.currentStep);
    FunkinAssert.areNear(7 + 104 / 120, Conductor.currentStepTime);

    step(); // 60

    FunkinAssert.areNear(FunkinTest.MS_PER_STEP * 60, Conductor.songPosition);
    Assert.areEqual(2, Conductor.currentBeat);
    Assert.areEqual(8, Conductor.currentStep);
    FunkinAssert.areNear(8.0, Conductor.currentStepTime);

    step(); // 61

    FunkinAssert.areNear(FunkinTest.MS_PER_STEP * 61, Conductor.songPosition);
    Assert.areEqual(2, Conductor.currentBeat);
    Assert.areEqual(8, Conductor.currentStep);
    FunkinAssert.areNear(8.0 + 8 / 60, Conductor.currentStepTime);

    step(179 - 61); // 179

    FunkinAssert.areNear(FunkinTest.MS_PER_STEP * 179, Conductor.songPosition);
    Assert.areEqual(5, Conductor.currentBeat);
    Assert.areEqual(23, Conductor.currentStep);
    FunkinAssert.areNear(23.0 + 52 / 60, Conductor.currentStepTime);

    step(); // 180 (3 seconds)

    FunkinAssert.areNear(FunkinTest.MS_PER_STEP * 180, Conductor.songPosition);
    Assert.areEqual(6, Conductor.currentBeat);
    Assert.areEqual(24, Conductor.currentStep); // 23.999 => 24
    FunkinAssert.areNear(24.0, Conductor.currentStepTime);

    step(); // 181 (3 + 1/60 seconds)
    // BPM has switched to 90!
    // 90 beats per minute = 1.5 beat per second
    // 1.5 beat per second = 1.5/60 beats per frame = 3/120 beats per frame
    // = 12/120 steps per frame

    FunkinAssert.areNear(FunkinTest.MS_PER_STEP * 181, Conductor.songPosition);
    Assert.areEqual(6, Conductor.currentBeat);
    Assert.areEqual(24, Conductor.currentStep);
    FunkinAssert.areNear(24.0 + 12 / 120, Conductor.currentStepTime);

    step(60 - 1 - 1); // 240 (4 seconds)

    FunkinAssert.areNear(FunkinTest.MS_PER_STEP * 239, Conductor.songPosition);
    Assert.areEqual(7, Conductor.currentBeat);
    Assert.areEqual(29, Conductor.currentStep);
    FunkinAssert.areNear(29.0 + 108 / 120, Conductor.currentStepTime);

    step(); // 240 (4 seconds)

    FunkinAssert.areNear(FunkinTest.MS_PER_STEP * 240, Conductor.songPosition);
    Assert.areEqual(7, Conductor.currentBeat);
    Assert.areEqual(30, Conductor.currentStep);
    FunkinAssert.areNear(30.0, Conductor.currentStepTime);

    step(); // 241 (4 + 1/60 seconds)

    FunkinAssert.areNear(FunkinTest.MS_PER_STEP * 241, Conductor.songPosition);
    Assert.areEqual(7, Conductor.currentBeat);
    Assert.areEqual(30, Conductor.currentStep);
    FunkinAssert.areNear(30.0 + 12 / 120, Conductor.currentStepTime);

    step(359 - 241); // 359 (5 + 59/60 seconds)

    FunkinAssert.areNear(FunkinTest.MS_PER_STEP * 359, Conductor.songPosition);
    Assert.areEqual(10, Conductor.currentBeat);
    Assert.areEqual(41, Conductor.currentStep);
    FunkinAssert.areNear(41 + 108 / 120, Conductor.currentStepTime);

    step(); // 360

    FunkinAssert.areNear(FunkinTest.MS_PER_STEP * 360, Conductor.songPosition);
    Assert.areEqual(10, Conductor.currentBeat);
    Assert.areEqual(42, Conductor.currentStep); // 41.999
    FunkinAssert.areNear(42.0, Conductor.currentStepTime);

    step(); // 361
    // BPM has switched to 180!
    // 180 beats per minute = 3 beat per second
    // 3 beat per second = 3/60 beats per frame
    // = 12/60 steps per frame

    FunkinAssert.areNear(FunkinTest.MS_PER_STEP * 361, Conductor.songPosition);
    Assert.areEqual(10, Conductor.currentBeat);
    Assert.areEqual(42, Conductor.currentStep);
    FunkinAssert.areNear(42.0 + 12 / 60, Conductor.currentStepTime);

    step(); // 362

    FunkinAssert.areNear(FunkinTest.MS_PER_STEP * 362, Conductor.songPosition);
    Assert.areEqual(10, Conductor.currentBeat);
    Assert.areEqual(42, Conductor.currentStep);
    FunkinAssert.areNear(42.0 + 24 / 60, Conductor.currentStepTime);

    step(3); // 365

    FunkinAssert.areNear(FunkinTest.MS_PER_STEP * 365, Conductor.songPosition);
    Assert.areEqual(10, Conductor.currentBeat);
    Assert.areEqual(43, Conductor.currentStep); // 42.999 => 42
    FunkinAssert.areNear(43.0, Conductor.currentStepTime);
  }
}

class ConductorState extends FlxState
{
  public var beatsHit:Int = 0;
  public var stepsHit:Int = 0;

  public function new()
  {
    super();
  }

  function beatHit():Void
  {
    beatsHit += 1;
  }

  function stepHit():Void
  {
    stepsHit += 1;
  }

  public override function create():Void
  {
    super.create();
    Conductor.beatHit.add(this.beatHit);
    Conductor.stepHit.add(this.stepHit);
  }

  public override function destroy():Void
  {
    super.destroy();
    Conductor.beatHit.remove(this.beatHit);
    Conductor.stepHit.remove(this.stepHit);
  }

  public override function update(elapsed:Float)
  {
    super.update(elapsed);

    // On each step, increment the Conductor as though the song was playing.
    Conductor.update(Conductor.songPosition + elapsed * Constants.MS_PER_SEC);
  }
}

package;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import funkin.util.DateUtil;

class MockTest extends FunkinTest
{
  public function new()
  {
    super();
  }

  @BeforeClass
  public function beforeClass() {}

  @AfterClass
  public function afterClass() {}

  @Before
  public function setup() {}

  @After
  public function tearDown() {}

  @Test
  public function testMock()
  {
    // Test that mocking works.

    var mockSprite = mockatoo.Mockatoo.mock(flixel.FlxSprite);
    var mockAnim = mockatoo.Mockatoo.mock(flixel.animation.FlxAnimationController);
    mockSprite.animation = mockAnim;

    var animData:funkin.data.animation.AnimationData =
      {
        name: "testAnim",
        prefix: "blablabla"
      };

    mockSprite.animation.addByPrefix("testAnim", "blablabla", 24, false, false, false);

    // Verify that the method was called once.
    // If not, a VerificationException will be thrown and the test will fail.
    mockatoo.Mockatoo.verify(mockAnim.addByPrefix("testAnim", "blablabla", 24, false, false, false), times(1));

    try
    {
      // Attempt to verify the method was called.
      // This should FAIL, since we didn't call the method.
      mockatoo.Mockatoo.verify(mockAnim.addByIndices("testAnim", "blablabla", [], "", 24, false, false, false), times(1));
      Assert.fail("Mocking function should have thrown but didn't.");
    }
    catch (_:mockatoo.exception.VerificationException)
    {
      // Expected.
    }
  }
}

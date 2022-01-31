package util;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxSort;
import flixel.FlxObject;

class SortUtil
{
	/**
	 * You can use this function in FlxTypedGroup.sort() to sort FlxObjects by their z-index values.
	 * The value defaults to 0, but by assigning it you can easily rearrange objects as desired.
	 */
	public static inline function byZIndex(Order:Int, Obj1:FlxObject, Obj2:FlxObject):Int
	{
		return FlxSort.byValues(Order, Obj1.zIndex, Obj2.zIndex);
	}

	/**
	 * Sorts the element in an FlxTypedGroup by their z-index values.
	 * @param group The group to sort.
	 */
	public static inline function sortByZIndex(group:FlxTypedGroup<FlxObject>)
	{
		group.sort(byZIndex, FlxSort.ASCENDING);
	}
}
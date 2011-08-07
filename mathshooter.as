//old numberEnemy array
//var numberArray:Array = new Array();
//new numberEnemy array
var numberEnemyArray:Array = new Array();
var gameSpeed:Number = 1.5;
var gameScore:Number = 0;
var gameMovementSpeed = 4;
var mathBulletSpeed:Number = 16;
var reloadSpeed:Number = 400;
var reloaded:Boolean = true;
var respawnCoolDown:Number = 400;
var permissionToRespawn:Boolean = true;

//minimum and maximum time allowed before the next enemy can spawn
var respMin:Number = 400;
var respMax:Number = 1000;

//minimum and maximum enemy fall speed
var fallMin:Number = 2;
var fallMax:Number = 7;

function revisionNotes()
{
	trace("Aug 06 0600 - Jay added blue background");
	trace("Aug 06 0715 - Jay added left and right controls");
	trace("Aug 06 0720 - Jay added a mathbullet MovieClip to library");
	trace("Aug 06 0735 - Jay added fireWeapon() function");
	trace("Aug 06 0748 - Jay added bullet placement to fireWeapon function");
	trace("** I am using this page as a reference for firing bullets: ");
	trace("** http://www.actionscript.org/resources/articles/873/2/Shooting-Bullets/Page2.html ");
	trace("Aug 06 0804 - Jay added bullet movement up the screen and clear when too high");
	trace("Aug 06 0905 - Jay moved the bullet.onEnterFrame key press code to the main timeline and off the MovieClip");
	trace("Aug 06 0941 - Jay added reload delay to gun turret");
	trace("Aug 06 0957 - Jay reworking the addNumberEnemy function");
	trace("Aug 06 1008 - Jay - enemies now fall down the screen and disappear");
	trace("Aug 06 1017 - Jay - enemies now fall at random rates");
	trace("Aug 06 1051 - Jay - enemies now respawn along the top row at random rates");
	//trace bla bla bla
}

function initGame()
{
	revisionNotes();
	var stageBG:MovieClip = attachMovie("stageBG", "stageBG", this.getNextHighestDepth());
	stageBG._width = Stage.width;
	stageBG._height = Stage.height;
	addShooter(Stage.width / 2,Stage.height);
	runGame();
}

function runGame()
{
	_root.onEnterFrame = function()
	{
		if (permissionToRespawn)
		{
			spawnEnemies();
		}
		updateScore();
	}
}

/*
function updateScore()
{
trace("score updated");
gameScore += 1;
trace("gameScore = "+gameScore);
}
*/

function addShooter(x:Number, y:Number)
{
	var shooter:MovieClip = attachMovie("shooter", "shooter", this.getNextHighestDepth());
	shooter._x = x;
	shooter._y = y - shooter._height;
	//movement with LEFT/RIGHT and SPACEBAR to fire
	shooter.onEnterFrame = function()
	{
		if (Key.isDown(Key.LEFT) && shooter._x > 0)
		{
			shooter._x -= gameMovementSpeed;
		}

		if (Key.isDown(Key.RIGHT) && shooter._x < 240 - shooter._width)
		{
			shooter._x += gameMovementSpeed;
		}

		if (Key.isDown(Key.SPACE))
		{
			_root.fireWeapon();
		}
	};
}

/*
////////////
//  THIS IS THE ORIGINAL ADD ENEMY FUNCTION
////////////
function addNumberEnemy(x:Number, y:Number)
{
	var number:MovieClip = attachMovie("number", "number_" + this.getNextHighestDepth(), this.getNextHighestDepth());
	number._x = x;
	number._y = y;
	numberArray.push(number);
}
*/

////////////
//  THIS IS THE NEW ADD ENEMY FUNCTION
////////////
function addNumberEnemy(x:Number, y:Number)
{
	var numberEnemy:MovieClip = attachMovie("numberEnemy", "numberEnemy_"+this.getNextHighestDepth(), this.getNextHighestDepth());
	numberEnemy._x = x+10;
	numberEnemy._y = y;
	//assign a random fall speed to this enemy, providing slowest and fastest limits as arguments
	var myFallSpeed = getRandomFallSpeed(fallMin,fallMax);
	numberEnemy.onEnterFrame = function()
	{
		numberEnemy._y += myFallSpeed;
			if (this._y >= shooter._y)
			{
				this.removeMovieClip();
				this.unloadMovie();
			}
	}
	numberEnemyArray.push(numberEnemy);
}

function getRandomFallSpeed(lower:Number,upper:Number)
{
	var newFallSpeed:Number = random(upper-lower) + lower;
	return newFallSpeed;
}

function spawnEnemies():Void
{
	//trace("spawn function called!");
	for (i = 0; i < 6; i++)
	{
		//trace("spawn iteration number "+i);
		if (random(2) == 1)
		{
			//trace("condition true for iteration number "+i);
			//trace(respawnTimer);
			addNumberEnemy( ( random(5) + 1 ) * 40,40);
			startRespawnTimer();
			return;
		}
	}
}

function startRespawnTimer()
{
	permissionToRespawn = false;
	respawnCoolDown = random(respMax - respMin) + respMin;
	respawnTimer = setTimeout(okToSpawnAgain, respawnCoolDown);
}

function okToSpawnAgain()
{
	permissionToRespawn = true;
}

//////////////////////////////////////////////
///  NOT USING THIS FUNCTION ANYMORE
/*///////////////////////////////////////////
function NumberDrop()
{
	for (i = 0; i < numberArray.length; i++)
	{
		var number:MovieClip = numberArray[i];
		number._y += gameSpeed;
		if (number._y > stage.height)
		{
			removeNumberEnemy(i);
		}
		//numberArray[i]._y -= 1*gameSpeed;  
	}
}
*/////////////////////////////////////////////

function fireWeapon()
{
	//if the gun is reloaded, then we can fire again
	if (reloaded)
	{

		trace("FIRE WEAPON!");
		// ***** using bulletW variable to count multiple bullets on the stage, 
		// ***** I don't know the typical naming convention but I thought "bullet_WhichOne?" so "bulletW"
		bulletW = _root.getNextHighestDepth();
		var mathBullet:MovieClip = _root.attachMovie("mathBullet", "mathBullet_" + bulletW, bulletW);
		mathBullet._x = shooter._x + shooter._width / 2;
		mathBullet._y = shooter._y;
		mathBullet.onEnterFrame = function()
		{
			//trace("moving bullet_" + bulletW + " up the screen");
			this._y -= mathBulletSpeed;
			if (this._y < 0)
			{
				//trace("bullet_" + bulletW + " vanished off the screen");
				this.removeMovieClip();
				this.unloadMovie();
			}
		}
		unloadGun();
	}
}

function unloadGun()
{
	trace("unload function called");
	reloaded = false;
	var timer:Number = setTimeout(reloadGun, reloadSpeed);
}

function reloadGun()
{
	trace("gun is now reloaded");
	reloaded = true;
}

/*
function removeNumberEnemy(w)
{
numberArray.splice(w, 1);
removeMovieClip

}
*/

initGame();
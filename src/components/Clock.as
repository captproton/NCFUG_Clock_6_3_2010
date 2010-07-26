package components
{
	import flash.display.Graphics;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.formatters.DateBase;

	public class Clock extends UIComponent
	{
		public function Clock()
		{
			super();
			
			this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
		}
		
		//
		// -------------- public API -------------------------------
		//
		
		//
		// accessors for hour hand
		//
		private var thisHour:Number = 0;
		public function get hour():Number
		{
			return thisHour;
		}
		public function set hour(inHour:Number):void
		{
			if(inHour != thisHour)
			{
				thisHour = inHour;
				this.invalidateDisplayList();
			}
		}
		
		//
		// accessors for minute hand
		//
		private var thisMinute:Number = 0;
		public function get minute():Number
		{
			return thisMinute;
		}
		public function set minute(inMinute:Number):void
		{
			if(inMinute != thisMinute)
			{
				thisMinute = inMinute;
				this.invalidateDisplayList();
			}
		}
		
		//
		// accessors for seconds hand
		//
		private var thisSecond:Number = 0;
		public function get second():Number
		{
			return thisSecond;
		}
		public function set second(inSecond:Number):void
		{
			if(inSecond != thisSecond)
			{
				thisSecond = inSecond;
				this.invalidateDisplayList();
			}
		}
		
		/**
		 * determine if the clock is running 
		 * 
		 * @return true if the clock is running, false if not
		 */
		public function get isRunning():Boolean
		{
			return thisIsRunning;
		}
		private var thisIsRunning:Boolean = false;
		
		/**
		 * start the clock running 
		 */
		public function start():void
		{
			if(!isRunning)
			{
				clockTimer.addEventListener(TimerEvent.TIMER, onTimer,false,0,true);
				clockTimer.start();
				thisIsRunning = true;
			}
		}
		
		/**
		 * stop the clock 
		 */
		public function stop():void
		{
			if(isRunning)
			{
				thisIsRunning = false;
				clockTimer.stop();
				clockTimer.removeEventListener(TimerEvent.TIMER, updateClock,false);
			}
		}
		
		//
		// --------------------- Life cycle ---------------------------
		//

		/**
		 * Override of life cycle method for drawing the component.
		 * 
		 * NOTE: Drawing is done in a local coordinate system where
		 *       the implicit top and left are zero.
		 *  
		 * @param unscaledWidth width of drawing area
		 * @param unscaledHeight height of drawing area
		 * 
		 */
		override protected function updateDisplayList(
			unscaledWidth:Number, 
			unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if((unscaledWidth > 0) && (unscaledHeight > 0))
			{
				var size:Number = Math.min(unscaledWidth, unscaledHeight);
				var radius:Number = size / 2;
				var left:Number = (unscaledWidth - size) / 2;
				var top:Number = (unscaledHeight - size) / 2;
				var centerX:Number = left + radius;
				var centerY:Number = top + radius;
				
				// calculate angle of clock hands
				var hourAngle:Number = (360.0 * this.hour) / 12;
				var minuteAngle:Number = (360.0 * this.minute) / 60;
				var secondAngle:Number = (360.0 * this.second) / 60;
				
				// calculate end point of each clock hand
				var theHourPoint:Point = ellipsePerimeterPoint(centerX, centerY, radius * 0.6, radius * 0.6, hourAngle);
				var theMinutePoint:Point = ellipsePerimeterPoint(centerX, centerY, radius * 0.9, radius * 0.9, minuteAngle);
				var theSecondPoint:Point = ellipsePerimeterPoint(centerX, centerY, radius * 0.95, radius * 0.95, secondAngle);
				
				// grag local copy of graphics context for efficiency
				var g:Graphics = this.graphics;
				g.clear();	// remove prior vectors
				
				// draw the clock face
				g.lineStyle(10, 1);
				g.beginFill(0xc0c0c0, 1);
				g.drawCircle(centerX, centerY, radius);
				g.endFill();
				
				// draw the minute hand
				g.moveTo(centerX, centerY);
				g.lineTo(theMinutePoint.x, theMinutePoint.y);
				
				// draw the hour hand
				g.moveTo(centerX, centerY);
				g.lineTo(theHourPoint.x, theHourPoint.y);
				
				// draw the second hand
				g.lineStyle(3, 0, 1);
				g.moveTo(centerX, centerY);
				g.lineTo(theSecondPoint.x, theSecondPoint.y);
			}
		}
		
		//
		// --------------------- private helpers ----------------------
		//
		
		/**
		 * calculate a point on the perimeter of an ellipse.
		 *  
		 * @param centerX horizontal center
		 * @param centerY vertical center
		 * @param radiusX horizontal radius
		 * @param radiusY vertical radius
		 * @param angleInDegrees (duh)
		 * @return Point on the perimeter of the ellipse
		 * 
		 */
		private function ellipsePerimeterPoint(
			centerX:int, 
			centerY:int, 
			radiusX:Number, 
			radiusY:Number, 
			angleInDegrees:Number)
			: Point
		{
            // keep total angle within 360
            if (angleInDegrees >= 360) 
            {
				angleInDegrees %= 360;	// calc remainder modulo 360
            }

			//
			// convert angle to radians
			//
            var angle:Number = angleInDegrees;
			angle = (angle / 180.0) * Math.PI;


			//
			// use parametric equation for circle to calc point on perimeter
			//
			var x:int = centerX + Math.sin(angle) * radiusX;
			var y:int = centerY - Math.cos(angle) * radiusY;// note: we subtract here because graphics coordinate system is flipped
			
			return new Point(x,y);
		}
		
		/**
		 * update the clock with the current time. 
		 */
		private function updateClock():void
		{
			var time:Date = new Date();	// get current date and time
			
			this.hour = time.hours;
			this.minute = time.minutes;
			this.second = time.seconds;
		}
		
		
		/**
		 * accessor for clock timer.
		 * NOTE: this does lazy initialization of the timer. 
		 * 
		 * @return the clock timer.
		 */
		private function get clockTimer():Timer
		{
			if(null == thisTimer)
			{
				thisTimer = new Timer(500);	// 500 milliseconds (two samples per second)
			}
			return thisTimer;
		}
		private var thisTimer:Timer = null;
				
				
		//
		// ------------------- Events ---------------------------
		//
		protected function onCreationComplete(theEvent:FlexEvent):void
		{
			updateClock();
		}
		
		protected function onTimer(theEvent:TimerEvent):void
		{
			updateClock();
		}
		
		
	}
}
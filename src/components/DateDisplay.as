package components
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.controls.Label;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;

	public class DateDisplay extends UIComponent
	{
		public function DateDisplay()
		{
			super();
			
			this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
		}
				
		private var thisLabel:Label = null;
		public function get dateLabel():Label
		{
			if(null == thisLabel)
			{
				thisLabel = new Label();
			}
			return thisLabel;
		}
		
		override protected function createChildren():void
		{
			this.addChild(dateLabel);
		}
		
		override protected function measure():void
		{
			super.measure();
			
			this.minHeight = dateLabel.getExplicitOrMeasuredHeight();
			this.minWidth = dateLabel.getExplicitOrMeasuredWidth();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			dateLabel.setActualSize(
				dateLabel.getExplicitOrMeasuredWidth(),
				dateLabel.getExplicitOrMeasuredHeight());
				
			dateLabel.move(0, 0);
		}
		
		private var thisYear:Number = 0;
		private var thisMonth:Number = 0;
		private var thisDayOfMonth:Number = 0;
		private function updateDate():void
		{
			var now:Date = new Date();
			
			if((now.fullYear != thisYear)
				|| (now.month != thisMonth)
				|| (now.day != thisDayOfMonth))
			{
				thisYear = now.fullYear;
				thisMonth = now.month;
				thisDayOfMonth = now.day;
				
				dateLabel.text = 
					thisMonth.toString() + "/" 
					+ thisDayOfMonth.toString() + "/"
					+ thisYear;
			}
		}
		
		/**
		 * accessor for clock timer.
		 * NOTE: this does lazy initialization of the timer. 
		 * 
		 * @return the clock timer.
		 */
		private function get dateTimer():Timer
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
			updateDate();
			dateTimer.addEventListener(TimerEvent.TIMER, onTimer,false,0,true);
			dateTimer.start();
		}
		
		protected function onTimer(theEvent:TimerEvent):void
		{
			updateDate();
		}
		
	}
}
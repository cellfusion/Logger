package jp.cellfusion.logger 
{
	import flash.system.Capabilities;
	import flash.system.System;

	/**
	 * @author cellfusion
	 * 
	 * Logger ライブラリ
	 * initialize 時に出力するレベルと出力先を設定します。
	 *
	 *
	 * レベル : デフォルトは何も出力しない
	 * 
	 * レベルは下記のように必要な物だけ選択することも出来ます。
	 * Logger.initialize(Logger.LEVEL_TRACE | Logger.LEVEL_INFO | Logger.LEVEL_FATAL);
	 * 
	 * 下記のようにも設定できます。（Error 以外を出力）
	 * Logger.initialize(parseInt("101111", 2));
	 * 
	 * flex では trace が消せないので下記のように指定して出力しないように出来ます。
	 * 新しい flex だと option で消せるようになったぽいですね
	 * Logger.initialize(Logger.LEVEL_NONE);
	 * 
	 * SOS Max
	 * http://www.sos.powerflasher.com/developer-tools/sosmax/home/
	 */
	public class Logger 
	{
		public static const LEVEL_NONE:uint = 0;
		public static const LEVEL_DEBUG:uint = 1;
		public static const LEVEL_INFO:uint = 2;
		public static const LEVEL_WARNING:uint = 4;
		public static const LEVEL_ERROR:uint = 8;
		public static const LEVEL_FATAL:uint = 16;
		public static const LEVEL_ALL:uint = LEVEL_DEBUG | LEVEL_INFO | LEVEL_WARNING | LEVEL_ERROR | LEVEL_FATAL;
		private static var _level:uint;
		private static var _ready:Boolean = false;
		private static var _loggers:Vector.<ILogger>;

		/**
		 * @param level 出力レベル
		 * @param logger 出力先
		 * 
		 * 出力するレベルを選択
		 */
		public static function initialize(level:uint = 0, logger:Vector.<ILogger> = null):void
		{
			_level = level;

			if (logger == null) {
				_loggers = new Vector.<ILogger>();
				_loggers.push(new TraceLogger());
			} else {
				_loggers = logger;
			}
			
			_ready = true;
		}

		/**
		 * debug レベルのログを出力
		 */
		public static function debug(...message:Array):void 
		{
			if ((_level & LEVEL_DEBUG) == LEVEL_DEBUG) log(LEVEL_DEBUG, message);
		}

		/**
		 * info レベルのログを出力
		 */
		public static function info(...message:Array):void 
		{
			if ((_level & LEVEL_INFO) == LEVEL_INFO) log(LEVEL_INFO, message);
		}

		/**
		 * 
		 */
		public static function warning(...message:Array):void 
		{
			if ((_level & LEVEL_WARNING) == LEVEL_WARNING) log(LEVEL_WARNING, message);
		}

		/**
		 * 
		 */
		public static function error(...message:Array):void 
		{
			if ((_level & LEVEL_ERROR) == LEVEL_ERROR) log(LEVEL_ERROR, message);
		}

		/**
		 * 
		 */
		public static function fatal(...message:Array):void 
		{
			if ((_level & LEVEL_FATAL) == LEVEL_FATAL) log(LEVEL_FATAL, message);
		}

		/**
		 * スタックトレース
		 */
		public static function stackTrace():void
		{
			if (!Capabilities.isDebugger) return;

			var st:String = new Error().getStackTrace();
			log(LEVEL_INFO, [st]);
		}

		/**
		 * 
		 */
		private static function log(key:uint, message:Array):void
		{
			if(!_ready) {
				initializeError();
				return;
			}

			var m:String = "";
			for (var i:uint = 0; i < message.length; i++) {
				if (i > 0) m += ", ";
				m += message[i];
			}
			
			for each (var l:ILogger in _loggers) {
				l.output(key, m);
			}
		}

		private static function initializeError():void 
		{
			throw new Error("Logger initialize error.");
		}

		public static function get level():uint 
		{
			return _level;
		}

		static public function get ready():Boolean 
		{
			return _ready;
		}
	}
}
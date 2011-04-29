#
#  AppDelegate.rb
#  Stack Exchange Watcher
#
#  Created by Dylan Markow on 4/21/11.
#  Copyright 2011 __MyCompanyName__. All rights reserved.
#

class AppDelegate
  attr_accessor :window

  def applicationDidFinishLaunching(a_notification)
    initStatusBar setupMenu
    @se_watcher = SEWatcher.new
    GrowlApplicationBridge.setGrowlDelegate(self)
  end

  def setupMenu
    menu = NSMenu.new
    menu.initWithTitle 'FooApp'
    mi = NSMenuItem.new
    mi.title = 'Hello from MacRuby!'
    mi.action = 'sayHello:'
    mi.target = self
    menu.addItem mi
    menu
  end

  def sayHello(sender)
    GrowlApplicationBridge.notifyWithTitle("Test", description:"This is my test.", notificationName:"Test", iconData:nil, priority:0, isSticky:false,clickContext:"foo")
    @se_watcher.update
    puts @se_watcher.content
  end

  def growlNotificationWasClicked(context)
    puts context
  end

  def initStatusBar(menu)
    status_bar = NSStatusBar.systemStatusBar
    @status_item = status_bar.statusItemWithLength(NSVariableStatusItemLength)
    @status_item.setTitle "SO"
    @status_item.setMenu menu
  end
end

class SEWatcher
  attr_accessor :content
  def initialize
    @last_update_at = Time.now
  end

  def update
    @content = NSMutableString.alloc.initWithContentsOfURL(NSURL.URLWithString('http://stackoverflow.com'), encoding:NSUTF8StringEncoding, error:nil)
  end
end

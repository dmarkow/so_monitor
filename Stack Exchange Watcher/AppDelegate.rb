#
#  AppDelegate.rb
#  Stack Exchange Watcher
#
#  Created by Dylan Markow on 4/21/11.
#  Copyright 2011 __MyCompanyName__. All rights reserved.
#
require 'json'

class PreferencesWindowController < NSWindowController
  
end

class AppDelegate
  attr_accessor :window

  def applicationDidFinishLaunching(a_notification)
    initStatusBar setupMenu
    @se_watcher = SEWatcher.new

    
    
    @timer = NSTimer.scheduledTimerWithTimeInterval 60, target:self, selector:'sayHello:', userInfo:nil, repeats:true
    @timer.fire
    
  end
  
  def applicationWillResignActive(aNotification)
    puts "locked screen!"
  end

  def setupMenu
    menu = NSMenu.new
    menu.initWithTitle 'FooApp'
    mi = NSMenuItem.new
    mi.title = 'Hello from MacRuby!'
    mi.action = 'sayHello:'
    mi.target = self
    menu.addItem mi
    mi = NSMenuItem.new
    mi.title = "View Profile"
    mi.action = 'view_profile:'
    mi.target = self
    menu.addItem mi
    mi = NSMenuItem.new
    mi.title = "Quit"
    mi.action = 'quit:'
    mi.target = self
    menu.addItem mi
    menu
  end

  def quit(sender)
    exit
  end

  def view_profile(sender)
    NSWorkspace.sharedWorkspace.openURL(NSURL.URLWithString("http://stackoverflow.com/users/424300"))
  end

  def sayHello(sender)
    #GrowlApplicationBridge.notifyWithTitle("Test", description:"This is my test.", notificationName:"Test", iconData:nil, priority:0, isSticky:false,clickContext:"foo")
    puts sender.class
    @se_watcher.update
    @status_item.title = "#{@se_watcher.current_reputation}"

  end

  def growlNotificationWasClicked(context)
    puts context
  end

  def initStatusBar(menu)
    status_bar = NSStatusBar.systemStatusBar
    @status_item = status_bar.statusItemWithLength(NSVariableStatusItemLength)
    @status_item.image = NSImage.new.initWithContentsOfFile(NSBundle.mainBundle.pathForResource("so_icon", ofType:"png"))
    @status_item.setMenu menu
    @status_item.highlightMode = true
  end

end

class SEWatcher
  attr_accessor :content, :current_reputation
  def initialize
    @last_update_at = Time.now
    @current_reputation = 0
    @last_question_time = (Time.now).to_i
    GrowlApplicationBridge.setGrowlDelegate(self)
    @icon_data = NSData.alloc.initWithContentsOfURL(NSURL.fileURLWithPath(NSBundle.mainBundle.pathForResource("so", ofType:"png")))

  end

  def update
    
    
    @content = JSON.parse(NSMutableString.alloc.initWithContentsOfURL(NSURL.URLWithString('http://api.stackoverflow.com/1.1/users/424300'), encoding:NSUTF8StringEncoding, error:nil))
    new_rep = @content["users"].first["reputation"].to_i
    if @current_reputation != new_rep
      GrowlApplicationBridge.notifyWithTitle("Stack Overflow Reputation", description:"Your reputation has increased by #{new_rep - @current_reputation}!\n\nYour current reputation is: #{new_rep}", notificationName:"Test", iconData:@icon_data, priority:0, isSticky:true, clickContext:"http://stackoverflow.com/users/424300?tab=reputation#reppage_1-repview_time")
      @current_reputation = new_rep
    end
    str = "http://api.stackoverflow.com/1.1/questions?tagged=ruby%2Bor%2Bruby-on-rails-3%2Bor%2Bruby-on-rails&fromdate=#{@last_question_time}"
    puts "Time: #{@last_question_time}"
    puts "Querying: #{str}"

    @content = JSON.parse(NSMutableString.alloc.initWithContentsOfURL(NSURL.URLWithString(str)))
    puts @content
    questions = @content["questions"]
    puts "Downloaded #{questions.size} questions..."
    unless questions.size == 0
      @last_question_time = questions[0]["creation_date"].to_i + 1
      questions.each do |question|
        GrowlApplicationBridge.notifyWithTitle("Stack Overflow: New Question", description:question['title'], notificationName:'Test', iconData:@icon_data, priority:0, isSticky:true, clickContext:"http://stackoverflow.com/questions/#{question['question_id']}")
      end
    end
  end

  def growlNotificationWasClicked(context)
    NSWorkspace.sharedWorkspace.openURL(NSURL.URLWithString(context))
  end

end

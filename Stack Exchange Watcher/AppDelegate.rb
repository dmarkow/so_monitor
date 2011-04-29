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
        # Insert code here to initialize your application
        reg_data = {"ApplicationName" => "Stack Exchange Watcher", "AllNotifications" => ["Test"], "DefaultNotifications" => ["Test"]}
        
        @nc = NSDistributedNotificationCenter.defaultCenter
        @nc.postNotificationName("GrowlApplicationRegistrationNotification", object:nil, userInfo:reg_data, deliverImmediately:true)
    end
    def registrationDictionaryForGrowl
        
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
        puts "test"
        notification = {'NotificationName' => "Test", 'ApplicationName' => "Stack Exchange Watcher", 'NotificationTitle' => "Test", 'NotificationDescription' => "Test"}
        notification['NotificationPriority'] = 0
        notification['NotificationSticky'] = false
        @nc.postNotificationName('GrowlNotification', object:nil, userInfo:notification, deliverImmediately:true)

    end
    
    def initStatusBar(menu)
        status_bar = NSStatusBar.systemStatusBar
        @status_item = status_bar.statusItemWithLength(NSVariableStatusItemLength)
        @status_item.setTitle "SO"
        @status_item.setMenu menu


    end
end


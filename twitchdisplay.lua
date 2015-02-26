-- Written By CoolAcid
-- https://github.com/coolacid/ComputerCraft

-- Based on the original work by bacon_donut
-- http://pastebin.com/vhn1z23v
-- http://twitch.tv/bacon_donut

-- This is formatted to fit on a 1x3 wall of Advanced Monitors with an Advanced Computer connected to a side
-- To get this to work you need to edit the streamid variable then run these five commands:

-- label set SomeKindOfNameHere
-- pastebin get WdiT6sR5 bootstrap
-- bootstrap
-- github get coolacid/ComputerCraft/master/twitchdisplay.lua startup
-- startup

-- Twitch Name of the Streamer
streamid = "Bacon_Donut"

-- Set the Y line for where you want the different bits to go.
line_streamer = 1
line_followers = 3
line_follower = 4
line_viewers = 5

-- Set Justification
-- 1 - Left
-- 2 - Center
-- 3 - Right

justify_streamer = 1
justify_followers = 1
justify_follower = 1
justify_viewers = 1

-- SleepTime is how often to grab new data. Set here to one minute.
-- Set it too fast and twitch will flag you for spam
-- and stop giving you data
SleepTime = 60

-- Check to see if the JSON api exists. Otherwise, download it. 
if not fs.exists('json') then
	print("JSON API not found - Downloading")
	shell.run("pastebin get 4nRg9CHU json")
end

if not fs.exists('functions') then
	print("JSON API not found - Downloading")
	shell.run("github get coolacid/ComputerCraft/master/functions.lua functions")
end

os.loadAPI("json")
os.loadAPI("functions")

local m = peripheral.find("monitor")

m.setTextColor(colors.blue)
m.setTextScale(1)

function getFollowers()
  str = http.get("https://api.twitch.tv/kraken/channels/" .. streamid .. "/follows?limit=1").readAll()
  obj = json.decode(str)
  follows = json.encodePretty(obj._total)
  follower = json.encodePretty(obj.follows[1].user.name)
  follower = follower:gsub('"', '')
  return follows, follower
end

function getViewerCount()
  str = http.get("https://api.twitch.tv/kraken/streams/" .. streamid).readAll()
  obj = json.decode(str)
  if obj.stream == nil then
    return nil
  else
    return json.encodePretty(obj.stream.viewers)
  end
end

function localwrite(text, justify, line)
    if justify == 1 then
      -- Right
      m.setCursorPos(1,line)
      m.write(text)
    else if justify == 2 then
      centerText(m, text, line)
    else if justify == 3 then
      -- Not done yet
    end
end

while true do
  local status, live = pcall(getViewerCount)

  if status then 
    m.setCursorPos(1,line_streamer)
    if live == nil then
      m.setBackgroundColor(colors.white)
      m.clear()
      m.write(streamid)
      m.setCursorPos(1,line_viewers)  
      m.write("Live Viewers: Offline")
    else
      m.setBackgroundColor(colors.yellow)
      m.clear()
      m.write(streamid)
      m.setCursorPos(1,line_viewers)
      m.write("Live Viewers: " .. live)
    end
  else
      m.setBackgroundColor(colors.white)
      m.clear()
      m.write(streamid)
      m.setCursorPos(1,line_viewers)
      m.write("Live Viewers: ERROR")
  end

  local status, followers, follower = pcall(getFollowers)

  if status then
    localwrite("Twitch Followers: " .. followers, justify_followers, line_followers)

    m.setCursorPos(1,line_follower)
    localwrite("Last Follower: " .. follower, justify_follower, line_follower)
  else
    m.setCursorPos(1,line_followers)  
    localwrite("Twitch Followers: ERROR", justify_followers, line_followers)

    m.setCursorPos(1,line_follower)
    localwrite("Last Follower: ERROR", justify_follower, line_follower)
  end

  sleep(SleepTime)
end

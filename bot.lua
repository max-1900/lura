-- Start LuRa Bot | By @botcollege | Team @botcollege

URL = require "socket.url"
http = require "socket.http"
https = require "ssl.https"
ltn12 = require "ltn12"
serpent = require ("serpent")
db = require('redis')
redis = db.connect('127.0.0.1', 6379)
redis:select(5)
JSON = (loadfile "./libs/dkjson.lua")()
jsons = (loadfile "./libs/JSON.lua")()
tdbot = dofile("tdbot.lua")
utf8 = dofile('utf8.lua')
http.TIMEOUT = 10
MsgTime = os.time() - 60

--------------------  Functions  --------------

function loadconfig()
local data_config = io.open('./config.lua', "r")
if not data_config then
print(clr.red .. ">file configs/config.lua not found.\n".. clr.reset)
os.exit()
end
local config = (loadfile "./config.lua")()
return config
end
local config = loadconfig()
-----------------------------------------------
function sleep(n)
  os.execute("sleep " .. tonumber(n))
end
-----------------------------------------------
local function info_bot(extra, result)
our_id = result.id
end
assert (tdbot_function ({_ = "getMe",}, info_bot, nil))
local myusers = io.popen("whoami"):read("*a")
myusers = string.gsub(myusers, "^%s+", "")
myusers = string.gsub(myusers, "%s+$", "")
myusers = string.gsub(myusers, "[\n\r]+", " ")
redis:set("myuser", myusers)

------------------ The Rank --------------------
function is_bot(msg)
 if tonumber(our_id) == msg.senader_user_id then
return true
else
return false
end
end

function is_sudo(msg)
local var = false
for k,v in pairs(config.sudo_users) do
if msg.sender_user_id == v then
var = true
end
end
return var
end

function is_admin(msg) 
local hash = redis:sismember("adminbot",msg.sender_user_id)
if hash or is_sudo(msg) then
return true
else
return false
end
end

function is_owner(msg) 
local hash = redis:sismember("ownerlist"..msg.chat_id,msg.sender_user_id)
if hash or  is_admin(msg) or is_sudo(msg) then
return true
else
return false
end
end

function is_mod(msg) 
local hash = redis:sismember("modlist"..msg.chat_id,msg.sender_user_id)
if hash or is_sudo(msg) or is_admin(msg) or is_owner(msg) then
return true
else
return false
end
end

function is_member(msg)
return true
end
----------------------------------------------

function file_exi(name, path, suffix)
local fname = tostring(name)
local pth = tostring(path)
local psv = tostring(suffix)
for k,v in pairs(exi_file(pth, psv)) do
if fname == v then
return true
end
end
return false
end

----------------The File Function------------

function exi_file(path, suffix)
local files = {}
local pth = tostring(path)
local psv = tostring(suffix)
for k, v in pairs(scandir(pth)) do
if (v:match('.'..psv..'$')) then
table.insert(files, v)
end
end
return files
end

-------------The Alarm Function -------------

function alarm(sec,callback, data)
assert (tdbot_function ({
_ = 'setAlarm',
seconds = sec
}, callback or dl_cb, data or nil))
end

--------------------------------------------

function string:split(sep)
  local sep, fields = sep or ":", {}
  local pattern = string.format("([^%s]+)", sep)
  self:gsub(pattern, function(c) fields[#fields+1] = c end)
  return fields
end

----------------------------------------------

local function getParseMode(parse_mode)
  local P = {}
  if parse_mode then
    local mode = parse_mode:lower()
    if mode == 'markdown' or mode == 'md' then
      P._ = 'textParseModeMarkdown'
    elseif mode == 'html' then
      P._ = 'textParseModeHTML'
    end
  end
  return P
end

-----------------------------------------------

local function getChatId(chat_id)
  local chat = {}
  local chat_id = tostring(chat_id)
  if chat_id:match('^-100') then
    local channel_id = chat_id:gsub('-100', '')
    chat = {id = channel_id, type = 'channel'}
  else
    local group_id = chat_id:gsub('-', '')
    chat = {id = group_id, type = 'group'}
  end
  return chat
end

-----------------------------------------------

function kickuser(chat_id, user_id)
assert (tdbot_function ({
_ = "changeChatMemberStatus",
chat_id = chat_id,
user_id = user_id,
status = {
_ = "chatMemberStatusBanned"
},
}, dl_cb, nil))
end

-----------------------------------------------

local function getInputFile(file, conversion_str, expectedsize)
local input = tostring(file)
local infile = {}
if (conversion_str and expectedsize) then
infile = {
_ = 'inputFileGenerated',
original_path = tostring(file),
conversion = tostring(conversion_str),
expected_size = expectedsize
}
else
if input:match('/') then
infile = {_ = 'inputFileLocal', path = file}
elseif input:match('^%d+$') then
infile = {_ = 'inputFileId', id = file}
else
infile = {_ = 'inputFilePersistentId', persistent_id = file}
end
end
return infile
end

------------------MatkDown--------------------

function check_markdown(text) 
str = text
if str:match('_') then
output = str:gsub('_',[[\_]])
elseif str:match('*') then
output = str:gsub('*','\\*')
elseif str:match('`') then
output = str:gsub('`','\\`')
else
output = str
end
return output
end

------------------------------------------------

function ec_name(name) 
text = name
if text then
if text:match('[\32-\126]') then
text = text:gsub('[\32-\126]','')
end
return text
end
end

--------------------- Send Message --------------------

function sendMessage(chatid, replytomessageid, disablenotification,text,frombackground,parse_mode)
  assert (tdbot_function ({
    _ = 'sendMessage',
    chat_id = chatid,
    reply_to_message_id = replytomessageid,
    disable_notification = disablenotification or 0,
    from_background = frombackground or 1,
    reply_markup = nil,
    input_message_content = {
    _ = "inputMessageText",
	text = text,
    disable_web_page_preview = 1,
    clear_draft = 0,
    parse_mode = getParseMode(parse_mode),
    entities = {}
}  
}, callback or dl_cb, nil))
end

------------------ Send Photo ------------------------

function sendPhoto(chat_id, reply_to_message_id, photo, caption)
assert (tdbot_function ({
_= "sendMessage",
chat_id = chat_id,
reply_to_message_id = reply_to_message_id,
disable_notification = 0,
from_background = true,
reply_markup = nil,
input_message_content = {
_ = "inputMessagePhoto",
photo = getInputFile(photo),
added_sticker_file_ids = {},
width = 0,
height = 0,
caption = caption
},
}, dl_cb, nil))
end

---------------------- Send Document -------------------

function sendDocument(chat_id,reply_to_message_id, document, caption)
assert (tdbot_function ({
_= "sendMessage",
chat_id = chat_id,
reply_to_message_id = reply_to_message_id,
disable_notification = 0,
from_background = true,
reply_markup = nil,
input_message_content = {
_ = 'inputMessageDocument',
document = getInputFile(document),
caption = tostring(caption)
},
}, dl_cb, nil))
end

------------------- Send Sticker ---------------------

function sendSticker(chat_id, reply_to_message_id, sticker_file)
assert (tdbot_function ({
_= "sendMessage",
chat_id = chat_id,
reply_to_message_id = reply_to_message_id,
disable_notification = 0,
from_background = true,
reply_markup = nil,
input_message_content = {
_ = 'inputMessageSticker',
sticker = getInputFile(sticker_file),
width = 1280,
height = 1280
},
}, dl_cb, nil))
end

------------------ Send Mention -----------------------

function sendMention(chat_id, user_id, msg_id, text, offset, length)
assert (tdbot_function ({
_ = "sendMessage",
chat_id = chat_id,
reply_to_message_id = msg_id,
disable_notification = 0,
from_background = true,
reply_markup = nil,
input_message_content = {
_ = "inputMessageText",
text = text,
disable_web_page_preview = 1,
clear_draft = false,
entities = {[0] = {
offset = offset,
length = length,
_ = "textEntity",
type = {
user_id = user_id,
 _ = "textEntityTypeMentionName"}
}}}}, dl_cb, nil))
end

---------------------- Get Chat History --------------------

function getChatHistory(chat_id, from_message_id, offset, limit,dl_cb)
tdbot_function ({
_ = "getChatHistory",
chat_id = chat_id,
from_message_id = from_message_id,
offset = offset,
limit = limit
}, dl_cb, nil)
end

-----------------------------------------------

function getStickerSet(setid, callback)
  assert (tdbot_function ({
    _ = 'getStickerSet',
    set_id = setid
  }, callback or dl_cb, nil))
end

-----------------------------------------------

function getFile(fileid, callback)
  assert (tdbot_function ({
    _ = 'getFile',
    file_id = fileid
  }, callback or dl_cb))
end

-----------------------------------------------

function getFilePersistent(persistentfileid, filetype, callback)
  assert (tdbot_function ({
    _ = 'getFilePersistent',
    persistent_file_id = tostring(persistentfileid),
    file_type = FileType
  }, callback or dl_cb))
end

-----------------------------------------------

function searchPublicChat(username, dl_cb)
  assert (tdbot_function ({
    _ = 'searchPublicChat',
    username = tostring(username)
  },  dl_cb, nil))
end

-----------------------------------------------

function getUserProfilePhotos(user_id, offset, limit, callback, data)
    assert (tdbot_function ({
            _ = 'getUserProfilePhotos',
            user_id = user_id,
            offset = offset,
            limit = limit
        }, callback or dl_cb, data or nil)
	)
end

-----------------------------------------------

function downloadFile(fileid, priorities)
  assert (tdbot_function ({
    _ = 'downloadFile',
    file_id = fileid,
    priority = priorities
  }, callback or dl_cb, nil))
end

-----------------------------------------------

function getFile(fileid,dl_cb)
assert (tdbot_function ({
_ = 'getFile',
file_id = fileid
}, dl_cb, nil))
end

-----------------------------------------------

function getSupportUser(callback)
  assert (tdbot_function ({
    _ = 'getSupportUser'
  }, callback or dl_cb, nil))
end

-----------------------------------------------

function deleteMessagesFromUser(chat_id, user_id)
tdbot_function ({
_ = "deleteMessagesFromUser",
chat_id = chat_id,
user_id = user_id
}, dl_cb, nil)
end

-----------------------------------------------

function deleteMessages(chat_id, message_ids)
tdbot_function ({
_= "deleteMessages",
chat_id = chat_id,
message_ids = message_ids
}, dl_cb, nil)
end

-----------------------------------------------

local function getMessage(chat_id, message_id,dl_cb)
tdbot_function ({
_ = "getMessage",
chat_id = chat_id,
message_id = message_id
}, dl_cb, nil)
end

-----------------------------------------------

function getChat(chatid,dl_cb)
assert (tdbot_function ({
_ = 'getChat',
chat_id = chatid
}, dl_cb, nil))
end

-----------------------------------------------

function getUser(user_id, dl_cb)
assert (tdbot_function ({
_ = 'getUser',
user_id = user_id
}, dl_cb, nil))
end

-----------------------------------------------

local function getUserFull(user_id,dl_cb)
assert (tdbot_function ({
_ = "getUserFull",
user_id = user_id
}, dl_cb, nil))
end

-----------------------------------------------

function pinChannelMessage(channelid, messageid)
  assert (tdbot_function ({
    _ = 'pinChannelMessage',
    channel_id = getChatId(channelid).id,
    message_id = messageid,
  }, callback or dl_cb, nil))
end

-----------------------------------------------

function unpinChannelMessage(channelid)
  assert (tdbot_function ({
    _ = 'unpinChannelMessage',
    channel_id = getChatId(channelid).id
  }, callback or dl_cb, nil))
end

-----------------------------------------------

function getChannelFull(channelid,dl_cb)
assert (tdbot_function ({
 _ = 'getChannelFull',
channel_id = getChatId(channelid).id
}, dl_cb, nil))
end

-----------------------------------------------

function importChatInviteLink(invitelink, callback, data)
  assert (tdbot_function ({
    _ = 'importChatInviteLink',
    invite_link = tostring(invitelink)
  }, callback or dl_cb, data))
end

-----------------------------------------------

function exportChatInviteLink(chatid, callback)
  assert (tdbot_function ({
    _ = 'exportChatInviteLink',
    chat_id = chatid
  }, callback or dl_cb, nil))
end

-----------------------------------------------

function blockUser(userid, callback, data)
  assert (tdbot_function ({
    _ = 'blockUser',
    user_id = userid
  }, callback or dl_cb, data))
end

-----------------------------------------------

function unblockUser(userid, callback, data)
  assert (tdbot_function ({
    _ = 'unblockUser',
    user_id = userid
  }, callback or dl_cb, data))
end

-----------------------------------------------

function getBlockedUsers(off, lim, callback, data)
  assert (tdbot_function ({
    _ = 'getBlockedUsers',
    offset = off,
    limit = lim
  }, callback or dl_cb, data))
end

-----------------------------------------------

function getStickerEmojis(sticker_path, callback, data)
  assert (tdbot_function ({
    _ = 'getStickerEmojis',
    sticker = getInputFile(sticker_path)
  }, callback or dl_cb, data))
end

-----------------------------------------------

function setProfilePhoto(photo_path, callback, data)
  assert (tdbot_function ({
    _ = 'setProfilePhoto',
    photo = getInputFile(photo_path)
  }, callback or dl_cb, data))
end

-----------------------------------------------

function deleteProfilePhoto(profilephotoid, callback, data)
  assert (tdbot_function ({
    _ = 'deleteProfilePhoto',
    profile_photo_id = profilephotoid
  }, callback or dl_cb, data))
end

-----------------------------------------------

function changeName(firstname, lastname, callback, data)
  assert (tdbot_function ({
    _ = 'changeName',
    first_name = tostring(firstname),
    last_name = tostring(lastname)
  }, callback or dl_cb, data))
end

-----------------Inline Query-------------------

function sendInlineQueryResultMessage(chatid, replytomessageid, disablenotification, frombackground, queryid, resultid, callback, data)
  assert (tdbot_function ({
    _ = 'sendInlineQueryResultMessage',
    chat_id = chatid,
    reply_to_message_id = replytomessageid,
    disable_notification = disablenotification,
    from_background = frombackground,
    query_id = queryid,
    result_id = tostring(resultid)
  }, callback or dl_cb, data))
end

function getInlineQuery(bot_user_id, chat_id, latitude, longitude, query,off, cb)
  assert (tdbot_function ({
_ = 'getInlineQueryResults',
 bot_user_id = bot_user_id,
chat_id = chat_id,
user_location = {
 _ = 'location',
latitude = latitude,
longitude = longitude 
},
query = tostring(query),
offset = tostring(off)
}, cb, nil))
end


-----------------------------------------------

function getChannelMembers(channelid, off, lim, mbrfilter, callback)
 -- local lim = lim or 200
--  lim = lim > 200 and 200 or lim

  assert (tdbot_function ({
    _ = 'getChannelMembers',
    channel_id = getChatId(channelid).id,
    filter = {
      _ = 'channelMembersFilter' .. mbrfilter,
      --query = tostring(searchquery)
    },
    offset = off,
    limit = lim
  }, callback or dl_cb, nil))
end
function Left(chat_id, user_id)
assert (tdbot_function ({
_ = "changeChatMemberStatus",
chat_id = chat_id,
user_id = user_id,
status = {
_ = "chatMemberStatusLeft"
},
}, dl_cb, nil))
end

local function get_weather(location)
local BASE_URL = "http://api.openweathermap.org/data/2.5/weather"
local url = BASE_URL
url = url..'?q='..location..'&APPID=eedbc05ba060c787ab0614cad1f2e12b'
url = url..'&units=metric'
local b, c, h = http.request(url)
if c ~= 200 then return nil end
local weather = jsons:decode(b)
local city = weather.name
local country = weather.sys.country
local temp = 'دمای شهر '..city..' هم اکنون '..weather.main.temp..' درجه سانتی گراد می باشد\n____________________'
local conditions = 'شرایط فعلی آب و هوا : '
if weather.weather[1].main == 'Clear' then
conditions = conditions .. 'آفتابی☀'
elseif weather.weather[1].main == 'Clouds' then
conditions = conditions .. 'ابری ☁☁'
elseif weather.weather[1].main == 'Rain' then
conditions = conditions .. 'بارانی ☔'
elseif weather.weather[1].main == 'Thunderstorm' then
conditions = conditions .. 'طوفانی ☔☔☔☔'
elseif weather.weather[1].main == 'Mist' then
conditions = conditions .. 'مه 💨'
end
return temp .. '\n' .. conditions
end

------------------------------------------------

function download_to_file(url, file_name)
	local respbody = {}
	local options = {
	url = url,
	sink = ltn12.sink.table(respbody),
	redirect = true
	}
	local response = nil
	
	if url:starts('https') then
		options.redirect = false
		response = {https.request(options)}
	else
		response = {http.request(options)}
	end
	
	local code = response[2]
	local headers = response[3]
	local status = response[4]
	
	if code ~= 200 then return nil end
	
	file_name = file_name or get_http_file_name(url, headers)
	
	local file_path = "dwn/"..file_name
	file = io.open(file_path, "w+")
	file:write(table.concat(respbody))
	file:close()
	
	return file_path
end

-------------------------------------------------------

function string.starts(String, Start)
	return Start == string.sub(String,1,string.len(Start))
end

--------------------------------------------------------

function vardump(value)
print(serpent.block(value, {comment=false}))
end

--------------------------------------------------------

function addChatMember(chatid, userid, forwardlimit, callback, data)
  assert (tdbot_function ({
    _ = 'addChatMember',
    chat_id = chatid,
    user_id = userid,
    forward_limit = forwardlimit
  }, callback or dl_cb, data))
end

--------------------------------------------------------

function Forwarded(chat_id, from_chat_id, message_id)
assert (tdbot_function ({
_ = "forwardMessages",
chat_id = chat_id,
from_chat_id = from_chat_id,
message_ids = message_id,
disable_notification = 0,
from_background = 1
}, dl_cb, nil))
end

--------------------------------------------------------
local function sendAllMessage(chatid, replytomessageid, InputMessageContent, disablenotification, frombackground, replymarkup, callback, data)
  assert (tdbot_function ({
    _ = 'sendMessage',
    chat_id = chatid,
    reply_to_message_id = replytomessageid,
    disable_notification = disablenotification or 0,
    from_background = frombackground or 1,
    reply_markup = replymarkup,
    input_message_content = InputMessageContent
  }, callback or dl_cb, data))
end

sendAllMessage = sendAllMessage
function sendVoice(chat_id, reply_to_message_id, voice_file, voi_duration, voi_waveform, voi_caption, disable_notification, from_background, reply_markup, callback, data)
  local input_message_content = {
    _ = 'inputMessageVoice',
    voice = getInputFile(voice_file),
    duration = voi_duration or 0,
    waveform = voi_waveform,
    caption = tostring(voi_caption)
  }
  sendAllMessage(chat_id, reply_to_message_id, input_message_content, disable_notification, from_background, reply_markup, callback, data)
end

------------------Start The Command------------------------

function run(msg,data)
if msg then
if msg.date < tonumber(MsgTime) then
print('OLD MESSAGE')
return false
end
local user_id = msg.sender_user_id
local reply_id = msg.reply_to_message_id
local caption = msg.content.caption
local text = msg.content.text
if msg.chat_id then
local id = tostring(msg.chat_id)
if id:match('-100(%d+)') then
chat_type = 'supergroup'
elseif id:match('^(%d+)') then
chat_type = 'user'
else
chat_type = 'group'
end
end
if msg.content.text then
print(msg.content.text)
end
if (data._ == "updateNewMessage") or (data._ == "updateNewChannelMessage") then
local input = msg.content.text or msg.content.caption
text = (input or '')
end
if (data._ == "updateNewMessage") or (data._ == "updateNewChannelMessage") then
assert (tdbot_function ({_ = "openChat",chat_id = msg.chat_id}, dl_cb, nil) )
if msg.content._ == "messageSticker" then;sticker_id = '';local function get_cb(extra, result);if result.content then;sticker_id = result.content.sticker.sticker.id;downloadFile(sticker_id, 32);print("sticker dwn");end;end;getMessage(msg.chat_id, msg.id, get_cb)
elseif msg.content._ == "messagePhoto" then;photo_id = '';local function get_cb(extra, result);if result.content then;if result.content.photo.sizes[2] then;photo_id = result.content.photo.sizes[2].photo.id;else;photo_id = result.content.photo.sizes[1].photo.id;end;downloadFile(photo_id, 32);print("photo dwn");end;end;getMessage(msg.chat_id, msg.id, get_cb)
elseif msg.content._ == "messageVideo" then;video_id = '';local function get_cb(extra, result);if result.content then;video_id = result.content.video.video.id;end;downloadFile(gif_id, 32);print("video dwn");end;getMessage(msg.chat_id, msg.id, get_cb);end


------------------------------------------------------------------------------

local bot_token = config.token
local channel_inline = config.channel_id
local BotUsername = config.BotUsername

------------------------------------------------------------------------------

function is_JoinChannel(msg)
local url  = https.request('https://api.telegram.org/bot'..bot_token..'/getchatmember?chat_id=@'..channel_inline..'&user_id='..msg.sender_user_id)
if res ~= 200 then end
Joinchanel = jsons:decode(url)
if (not Joinchanel.ok or Joinchanel.result.status == "left" or Joinchanel.result.status == "kicked") and not is_sudo(msg) then
local function inline_query_cb(arg, data)
if data.results and data.results[0] then
sendInlineQueryResultMessage(msg.chat_id, msg.id, 0, 1, data.inline_query_id, data.results[0].id, dl_cb, nil)
end
end
sendMessage(msg.chat_id,msg.id, 1,"♦️لطفا برای استفاده از ربات در چنل ما جوین شوید\n"..config.channel_id, 1, 'md')
else
return true
end
end

--------------------------------------------------------------------------------
---The PvSendMessage Command
if msg and chat_type == 'user' then
redis:sadd("pvList",msg.sender_user_id)
local text1 =[[
▫️به ربات لورا خوش اومدید▫️
🔹 برای استفاده از لورا لطفا ربات را در گروه خود Import کنید 😁
🔸 https://t.me/botcollege?startgroup=add
-----------------------------------------
▫️Welcome To LuRa▫️
🔹For Use Robot Please Import Bot To Your Group
🔸 https://t.me/botcollege?startgroup=add

-----------------------------------------
راهنما
بعد از اد کردن ربات در گروه خود لطفا دستور پیکربندی را ارسال کنید

همچنین دستور راهنمای ربات دستور زیر است
`لورا راهنماییم کن`

♦️Creator @botcollege
♦️Channel @botcollege
]]
sendMessage(msg.chat_id,msg.id,1,text1,1,"html")
end

if text:match("^لورا$") and chat_type == 'group' then
local text1 =[[
سلام اگر این پیامو داری دریافت میکنی باید بدونی منو توی گروه آوردی
در صورتی که من فقط تو ابرگروه یا سوپرگروه کارمیکنم پس گروهتو ابرگروه یاسوپرگروه کن
]]
sendMessage(msg.chat_id,msg.id,1,text1,1,"html")
end

-- Import To The Group
--[[if text and text:match("^import (https://t.me/joinchat/%S+)$") or text:match("^import (https://telegram.me/joinchat/%S+)$") and chat_type == 'user' then
link = text:match("^import (https://t.me/joinchat/%S+)$") or text:match("^import (https://telegram.me/joinchat/%S+)$")
importChatInviteLink(link)
sendMessage(msg.chat_id,msg.id, 1,"حله وارد گروهت شدم : )\n\nلینک : "..link, 1, "html")
end]]
--- The Config Command

function set_config(msg)
local function config_cb(arg, data)
for k,v in pairs(data.members) do
local function config_mods(arg, data)
if data.username then
user_name = '@'..check_markdown(data.username)
else
user_name = check_markdown(data.first_name)
end
redis:sadd("modlist"..msg.chat_id,data.id,user_name)
end
assert (tdbot_function ({
_ = "getUser",
user_id = v.user_id
}, config_mods, {user_id=v.user_id}))			

if data.members[k].status._ == "chatMemberStatusCreator" then
owner_id = v.user_id
local function config_owner(arg, data)
if data.username then
user_name = '@'..check_markdown(data.username)
else
user_name = check_markdown(data.first_name)
end
redis:sadd("ownerlist"..msg.chat_id,data.id,user_name)
sendMessage(msg.chat_id, 0, 1,"حله اماده خدمتم لطفا روشنم کن با دستور | لورا پاشو|\n همچنین دستور راهنمای ربات هم \n `لورا راهنماییم کن`\n میباشد", 1, "md")
end
assert (tdbot_function ({
_ = "getUser",
user_id = owner_id
}, config_owner, {user_id=owner_id}))
end
end
end
getChannelMembers(msg.chat_id, 0, 200, 'Administrators', config_cb, {chat_id=msg.chat_id})
end
--Set Config
if text:match("^پیکربندی$") or text:match("^/start@botcollege$")then
set_config(msg)
redis:sadd("grouplist",msg.chat_id)
end
--SetCMD Command

if text:match("^setcmd owner$") and is_owner(msg)and is_JoinChannel(msg) then
redis:set("bot:cmd"..msg.chat_id,"owner")
sendMessage(msg.chat_id,msg.id,1,"فقط اونر گروه میتواند از ربات استفاده کند",1,"html")
end
if text:match("^setcmd mod$") and is_owner(msg)and is_JoinChannel(msg) then
redis:set("bot:cmd"..msg.chat_id,"mod")
sendMessage(msg.chat_id,msg.id,1,"اونر گروه و ادمین ها میتوانند از ربات استفاده کنند",1,"html")
end
if text:match("^setcmd all$") and is_owner(msg) and is_JoinChannel(msg)then
redis:set("bot:cmd"..msg.chat_id,"all")
sendMessage(msg.chat_id,msg.id,1,"تمامی کاربران میتوانند از ربات استفاده کنند",1,"html")
end
if redis:get("bot:cmd") == nil then
CMD = is_owner(msg)
end
if redis:get("bot:cmd") == "owner" then
CMD = is_owner(msg)
end
if redis:get("bot:cmd") == "mod" then
CMD = is_mod(msg)
end
if redis:get("bot:cmd") == "all" then
CMD = is_member(msg)
end
-----------------
--Set Answer

if text:match("^لورا بی ادب شو$")and is_owner(msg) and is_JoinChannel(msg) then
redis:set("bot:ans"..msg.chat_id,true)
sendMessage(msg.chat_id,msg.id,1,"بی ادب شدم حله",1,"html")
end
if text:match("^لورا با ادب شو$") and is_owner(msg) and is_JoinChannel(msg) then
redis:del("bot:ans"..msg.chat_id)
sendMessage(msg.chat_id,msg.id,1,"چشم با ادب میشم",1,"html")
end
if text:match("لورا بکنش") and is_mod(msg) then
sendMessage(msg.chat_id,reply_id, 1,'حاجی شل کن بااا', 1, 'md')
file = 'data/bokon.jpg'
sendSticker(msg.chat_id,reply_id,file, 512, 512, 1, nil, nil, dl_cb, nil)
function pm2()
sendMessage(msg.chat_id,msg.id, 1,'حله داداش ریختم توش', 1, 'md')
end
function pm3()
sendMessage(msg.chat_id,reply_id, 1,'بگوریز ای گاییده شده توسط من', 1, 'md')
end
alarm(4,pm2)
alarm(7,pm3)
end
if text:match("^بمیر$") then
if redis:get("bot:ans"..msg.chat_id) == nil then
sendMessage(msg.chat_id,msg.id,1,"اینطوری نگو بهم",1,"html")
else
sendMessage(msg.chat_id,msg.id,1,"خفه شو الاغ",1,"html")
end
end
--The SleepBot Command 
if text:match("^لورا بخواب$") and is_mod(msg) and is_JoinChannel(msg) then
redis:del('bot:off'..msg.chat_id)
if redis:get("bot:ans"..msg.chat_id) == nil then
sendMessage(msg.chat_id,msg.id,1,"چشم خاموش میشم!دیگه جوابی نمیدم تاروشنم کنید",1,"html")
else
sendMessage(msg.chat_id,msg.id,1,"اوک باو گاییدی خاموش میشم",1,"html")
end
elseif text:match("^لورا پاشو$") and is_mod(msg)and is_JoinChannel(msg) then
redis:set("bot:off"..msg.chat_id,true)
if redis:get("bot:ans"..msg.chat_id) == nil then
sendMessage(msg.chat_id,msg.id,1,"پاشدم حاضر و اماده :)",1,"html")
else
sendMessage(msg.chat_id,msg.id,1,"اوکی باو کصکش پاشدم حله",1,"html")
end
end
--- Checking The Bot is Off Or On
if redis:get('bot:off'..msg.chat_id)==nil then 
return false 
else 
--[[
if text:match("^لایک (.*)$") and is_JoinChannel(msg) and CMD then
local input = {
string.match(text, "لایک (.*)$")
} 
local function LuRa(arg, data)
sendInlineQueryResultMessage(msg.chat_id, msg.id, 0, 1, data.inline_query_id, data.results[0].id)
end
getInlineQueryResults(190601014, msg.chat_id, 0, 0, input[1], 0, LuRa, nil)
end
if text:match("^اهنگ (.*)$") and is_JoinChannel(msg) and CMD then
local input = {
string.match(text, "اهنگ (.*)$")
} 
local function LuRa(arg, data)
sendInlineQueryResultMessage(msg.chat_id, msg.id, 0, 1, data.inline_query_id, data.results[0].id)
end
getInlineQueryResults(117678843, msg.chat_id, 0, 0, input[1], 0, LuRa, nil)
end
]]
--if text:match("test") then

if text:match("^لورا ساعت عاشقی رو فعال کن$") and is_JoinChannel(msg) and is_mod(msg) then
redis:sadd("lovegp",msg.chat_id)
if redis:get("bot:ans"..msg.chat_id) == nil then
sendMessage(msg.chat_id,msg.id,1,"❤️اخ جون عشقو عاشقی حله🤪 فعال شد🚶🏻‍♂️ راس ساعت های عاشقی ربات پیام میده ساعت رو داخل گروه",1,"html")
else
sendMessage(msg.chat_id,msg.id,1,"ای باو کصلیسی های ساعت عاشقی شروع شد باز اوکی باو ساعت عاشقی رو روشن کردم حله",1,"html")
end
end
if text:match("^لورا ساعت عاشقی رو غیرفعال کن$") and is_JoinChannel(msg) and is_mod(msg) then
redis:srem("lovegp",msg.chat_id)
if redis:get("bot:ans"..msg.chat_id) == nil then
sendMessage(msg.chat_id,msg.id,1,"عههه چلا پس ساعتای عاشقی که خوب بود راس ساعت های پشت سرهم بهتون میگفتم به دوج دخترون میگفتید کیف میکرد ولی خب باشه غیرفعال شد",1,"html")
else
sendMessage(msg.chat_id,msg.id,1,"کصلیسیت تموم شد؟ حله کیرخر عاشقی اف شد",1,"html")
end
end
if text:match("^fuck$") and is_admin(msg)then
local lovegpd = redis:smembers("lovegp")
for k,v in pairs(lovegpd) do
text = "گپای عاشقی:["..k.."]\n"
end
sendMessage(msg.chat_id,0,1,text,1,"html")
end
local MCHAT = redis:smembers("lovegp")
local Time = os.date("%X")
if Time == "00:00" then
for k,v in pairs(MCHAT) do
sendMessage(v,0,1,"00:00:00 | Love ❤️",1,"html")
end
end
if Time == "01:01" then
for k,v in pairs(MCHAT) do
sendMessage(v,0,1,"01:01:01 | Love ❤️",1,"html")
end
end
if Time == "02:02" then
for k,v in pairs(MCHAT) do
sendMessage(v,0,1,"02:02:02 | Love ❤️",1,"html")
end
end
if Time == "03:03" then
for k,v in pairs(MCHAT) do
sendMessage(v,0,1,"03:03:03 | Love ❤️",1,"html")
end
end
if Time == "04:04" then
for k,v in pairs(MCHAT) do
sendMessage(v,0,1,"04:04:04 | Love ❤️",1,"html")
end
end
if Time == "05:05" then
for k,v in pairs(MCHAT) do
sendMessage(v,0,1,"05:05:05 | Love ❤️",1,"html")
end
end
if Time == "06:06" then
for k,v in pairs(MCHAT) do
sendMessage(v,0,1,"006:06:06 | Love ❤️",1,"html")
end
end
if Time == "07:07" then
for k,v in pairs(MCHAT) do
sendMessage(v,0,1,"07:07:07 | Love ❤️",1,"html")
end
end
if Time == "08:08" then
for k,v in pairs(MCHAT) do
sendMessage(v,0,1,"08:08:08 | Love ❤️",1,"html")
end
end
if Time == "09:09" then
for k,v in pairs(MCHAT) do
sendMessage(v,0,1,"09:09:09 | Love ❤️",1,"html")
end
end
if Time == "10:10" then
for k,v in pairs(MCHAT) do
sendMessage(v,0,1,"10:10:10 | Love ❤️",1,"html")
end
end
if Time == "11:11" then
for k,v in pairs(MCHAT) do
sendMessage(v,0,1,"11:11:11 | Love ❤️",1,"html")
end
end
if Time == "12:12" then
for k,v in pairs(MCHAT) do
sendMessage(v,0,1,"12:12:12 | Love ❤️",1,"html")
end
end
if Time == "13:13" then
for k,v in pairs(MCHAT) do
sendMessage(v,0,1,"13:13:13 | Love ❤️",1,"html")
end
end
if Time == "14:14" then
for k,v in pairs(MCHAT) do
sendMessage(v,0,1,"14:14:14 | Love ❤️",1,"html")
end
end
if Time == "15:15" then
for k,v in pairs(MCHAT) do
sendMessage(v,0,1,"15:15:15 | Love ❤️",1,"html")
end
end
if Time == "16:16" then
for k,v in pairs(MCHAT) do
sendMessage(v,0,1,"16:16:16 | Love ❤️",1,"html")
end
end
if Time == "17:17" then
for k,v in pairs(MCHAT) do
sendMessage(v,0,1,"17:17:17 | Love ❤️",1,"html")
end
end
if Time == "18:18" then
for k,v in pairs(MCHAT) do
sendMessage(v,0,1,"18:18:18 | Love ❤️",1,"html")
end
end
if Time == "19:19" then
for k,v in pairs(MCHAT) do
sendMessage(v,0,1,"19:19:19 | Love ❤️",1,"html")
end
end
if Time == "20:20" then
for k,v in pairs(MCHAT) do
sendMessage(v,0,1,"20:20:20 | Love ❤️",1,"html")
end
end
if Time == "21:21" then
for k,v in pairs(MCHAT) do
sendMessage(v,0,1,"21:21:21 | Love ❤️",1,"html")
end
end
if Time == "22:22" then
for k,v in pairs(MCHAT) do
sendMessage(v,0,1,"22:22:22 | Love ❤️",1,"html")
end
end
if Time == "23:23" then
for k,v in pairs(MCHAT) do
sendMessage(v,0,1,"23:23:23 | Love ❤️",1,"html")
end
end
local data = {'rock','paper','sci'}
local R = data[math.random(#data)]
if text:match("^لورا بازی (.*)$") and is_JoinChannel(msg) and CMD then
local input = text:match("^لورا بازی (.*)$")
if input == "کاغذ" then
if R == 'rock' then 
local text = "گلم تو انتخاب کردی: "..input.."\nمنم انتخابم: سنگ \nعه افرین تو بردی افریییییییین😍🥰"
sendMessage(msg.chat_id, msg.id, 1,text, 1, 'md')
elseif R == 'paper' then
local text = "گلم تو انتخاب کردی: "..input.."\nمنم انتخابم: کاغذ\nعه مساوی شدم😐🙈"
sendMessage(msg.chat_id, msg.id, 1,text, 1, 'md')
elseif R=='sci' then
local text = "گلم تو انتخاب کردی: "..input.."\nمنم انتخابم: قیچی\nعه من بردم😂😂توباختی🙈🙄 فداسرت🌸🌸"
sendMessage(msg.chat_id, msg.id, 1,text, 1, 'md')
end
end
if input == "سنگ" then
if R == 'sci' then 
local text = "گلم تو انتخاب کردی: "..input.."\nمنم انتخابم: قیچی\nعه افرین تو بردی افریییییییین😍🥰"
sendMessage(msg.chat_id, msg.id, 1,text, 1, 'md')
elseif R=='rock' then
local text = "گلم تو انتخاب کردی: "..input.."\nمنم انتخابم: سنگ\nعه مساوی شدم😐🙈"
sendMessage(msg.chat_id, msg.id, 1,text, 1, 'md')
elseif R=='paper' then
local text = "گلم تو انتخاب کردی: "..input.."\nمنم انتخابم: کاغذ\nعه من بردم😂😂توباختی🙈🙄 فداسرت🌸🌸"
sendMessage(msg.chat_id, msg.id, 1,text, 1, 'md')
end
end
if input == "قیچی" then
if R == 'paper' then 
local text = "گلم تو انتخاب کردی: "..input.."\nمنم انتخابم: کاغذ\nعه افرین تو بردی افریییییییین😍🥰"
sendMessage(msg.chat_id, msg.id, 1,text, 1, 'md')
elseif R=='sci' then
local text = "گلم تو انتخاب کردی: "..input.."\nمنم انتخابم: قیچی\nعه مساوی شدم😐🙈"
sendMessage(msg.chat_id, msg.id, 1,text, 1, 'md')
elseif R=='rock' then
local text = "گلم تو انتخاب کردی: "..input.."\nمنم انتخابم: سنگ\nعه من بردم😂😂توباختی🙈🙄 فداسرت🌸🌸"
sendMessage(msg.chat_id, msg.id, 1,text, 1, 'md')
end
end
end
if text:match("^لورا فالمو بگیر$") and is_JoinChannel(msg) and CMD then
local url = 'http://api.NovaTeamCo.ir/fal'
local file = download_to_file(url,'fal.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
--
--The Creating Sticker Command
elseif text:match("^پرنسس (.*)$") and is_JoinChannel(msg) and CMD then
local text10 = text:match("^پرنسس (.*)$") 
local url = "http://www.iloveheartstudio.com/-/p.php?t=%EE%BB%AA%0D%0A"..text10.."&bc=FF00A2&tc=FFFFFF&hc=FFF700&f=p&uc=true&ts=true&ff=PNG&w=500&ps=sq"
local file = download_to_file(url,"queen.webp")
sendSticker(msg.chat_id, 0, file)
elseif text:match("^شاه (.*)$") and is_JoinChannel(msg) and CMD then
local text2 = text:match("^شاه (.*)$") 
local url = "http://www.iloveheartstudio.com/-/p.php?t="..text2.."%0D%0A%EE%BB%AA&bc=FF0000&tc=ffffff&hc=FFF700&f=n&uc=true&ts=true&ff=PNG&w=500&ps=sq"
local file = download_to_file(url,"king.webp")
sendSticker(msg.chat_id, 0, file)

--
--FazSangin Command
elseif text:match("^لورا جمله فازسنگین بفرست$") and is_JoinChannel(msg) and CMD then
res = http.request('https://api.bot-dev.org/sangin/')
sendMessage(msg.chat_id,msg.id, 1,res, 1, 'md')
--
---Shabih Command
elseif text:match("^لورا به نظرت شبیه کیم$") and is_JoinChannel(msg) and CMD then
if redis:get("bot:ans"..msg.chat_id) == nil then
res = http.request('https://abolfazl.senatorhost.com/MoshAPI/Shabih.php')
sendMessage(msg.chat_id,msg.id, 1,res, 1, 'md')
else
res = http.request('https://abolfazl.senatorhost.com/Api/Shabih.php')
sendMessage(msg.chat_id,msg.id, 1,res, 1, 'md')
end
elseif text:match("^لورا هوای (.*)$") and is_JoinChannel(msg) and CMD then
local city = text:match("^لورا هوای (.*)$")
textz = get_weather(city)
if not textz then
sendMessage(msg.chat_id, 0, 1,"مکان وارد شده💩", 1, "html")
end
sendMessage(msg.chat_id, 0, 1,textz, 1, "html")
elseif text:match("^لورا صلوات$")and is_JoinChannel(msg) and CMD then
sendMessage(msg.chat_id,msg.id, 1,"ٱللَّهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ وَآلِ مُحَمَّد☺️📿", 1, 'md')
elseif text:match("^لورا من کیم$") and is_JoinChannel(msg) and CMD then
if redis:get("bot:ans"..msg.chat_id) == nil then
res = http.request('https://abolfazl.senatorhost.com/MoshAPI/To.php')
sendMessage(msg.chat_id,msg.id, 1,res, 1, 'md')
else
res = http.request('https://abolfazl.senatorhost.com/Api/To.php')
sendMessage(msg.chat_id,msg.id, 1,res, 1, 'md')
end
elseif text:match("^لورا به نظرت شغلم چیه$") and is_JoinChannel(msg) and CMD then
if redis:get("bot:ans"..msg.chat_id) == nil then
res = http.request('https://abolfazl.senatorhost.com/MoshAPI/Shoqle.php')
sendMessage(msg.chat_id,msg.id, 1,res, 1, 'md')
else
res = http.request('http://abolfazl.senatorhost.com/Api/Shoghl.php')
sendMessage(msg.chat_id,msg.id, 1,res, 1, 'md')
end
elseif text:match("^لورا یه جوک بگو$") and is_JoinChannel(msg) and CMD then
res = http.request('http://api.bot-dev.org/jock/')
sendMessage(msg.chat_id,msg.id, 1,res, 1, 'md')
elseif text:match("^لورا یه سخن بگو از بزرگان$") and is_JoinChannel(msg) and CMD then
res = http.request('http://abolfazl.senatorhost.com/Api/Sokhan.php')
sendMessage(msg.chat_id,msg.id, 1,res, 1, 'md')
elseif text:match("^لورا یه چیستان بگو$") and is_JoinChannel(msg) and CMD then
res = http.request('http://abolfazl.senatorhost.com/Api/Chistan.php')
sendMessage(msg.chat_id,msg.id, 1,res, 1, 'md')
elseif text:match("^لورا یچی بگو ندونم$") and is_JoinChannel(msg) and CMD then
res = http.request('https://api.bot-dev.org/danestani/')
sendMessage(msg.chat_id,msg.id, 1,res, 1, 'md')
elseif text:match("^لورا اخبار بگو$") and is_JoinChannel(msg) and CMD then
local url = http.request('http://api.khabarfarsi.net/api/news/latest/1?tid=*&output=json')
local jdat = jsons:decode(url)
local text = '♤`موضوع خبر` : '..jdat.items[1].title..'\n♤`لینک خبر` : '..jdat.items[1].link..'\n\n♤`موضوع خبر` : '..jdat.items[2].title..'\n♤`لینک خبر` : '..jdat.items[2].link..'\n\n♤`موضوع خبر` : '..jdat.items[3].title..'\n♤`لینک خبر` : '..jdat.items[3].link..'\n\n♤`موضوع خبر` : '..jdat.items[4].title..'\n♤`لینک خبر` : '..jdat.items[4].link..'\n\n♤`موضوع خبر` : '..jdat.items[5].title..'\n♤`لینک خبر` : '..jdat.items[5].link..'\n\n♤`موضوع خبر` : '..jdat.items[6].title..'\n♤`لینک خبر` : '..jdat.items[6].link..'\n\n♤`موضوع خبر` : '..jdat.items[7].title..'\n♤`لینک خبر` : '..jdat.items[7].link..'\n\n♤`موضوع خبر` : '..jdat.items[8].title..'\n♤`لینک خبر` : '..jdat.items[8].link..'\n\n♤`موضوع خبر` : '..jdat.items[9].title..'\n♤`لینک خبر` : '..jdat.items[9].link..'\n\n♤`موضوع خبر` : '..jdat.items[10].title..'\n♤`لینک خبر` : '..jdat.items[10].link
sendMessage(msg.chat_id,msg.id, 1,text, 1, 'md')
elseif text:match("^لورا یه شعر بگو$") and is_JoinChannel(msg) and CMD then
if redis:get("bot:ans"..msg.chat_id) == nil then
local url = http.request('http://c.ganjoor.net/beyt-json.php')
local jdat = jsons:decode(url)
local text = jdat.m1.."\n"..jdat.m2.."\n\n سروده شده توسط \n ——————————\n👤"..jdat.poet
sendMessage(msg.chat_id,msg.id, 1,text, 1, 'md')
else
res = http.request('http://abolfazl.senatorhost.com/Api/Kosesher.php')
sendMessage(msg.chat_id,msg.id, 1,res, 1, 'md')
end
elseif text:match("^لورا بچه کجام$") and is_JoinChannel(msg) and CMD then
if redis:get("bot:ans"..msg.chat_id) == nil then
res = http.request('https://abolfazl.senatorhost.com/LuRaApi/koja.php')
sendMessage(msg.chat_id,msg.id, 1,res, 1, 'md')
else
res = http.request('https://abolfazl.senatorhost.com/Api/Kojam.php	.php')
sendMessage(msg.chat_id,msg.id, 1,res, 1, 'md')
end
elseif text:match("^لورا زنم چطوریه$") and is_JoinChannel(msg) and CMD then
if redis:get("bot:ans"..msg.chat_id) == nil then
res = http.request('https://abolfazl.senatorhost.com/LuRaApi/Zan.php')
sendMessage(msg.chat_id,msg.id, 1,res, 1, 'md')
else
res = http.request('https://abolfazl.senatorhost.com/Api/Zan.php')
sendMessage(msg.chat_id,msg.id, 1,res, 1, 'md')
end
elseif text:match("^لورا شوهرم کیه$") and is_JoinChannel(msg) and CMD then
if redis:get("bot:ans"..msg.chat_id) == nil then
res = http.request('https://abolfazl.senatorhost.com/LuRaApi/shohar.php')
sendMessage(msg.chat_id,msg.id, 1,res, 1, 'md')
else
res = http.request('https://abolfazl.senatorhost.com/Api/Mard.php')
sendMessage(msg.chat_id,msg.id, 1,res, 1, 'md')
end
elseif text:match("^لورا چطوری میمیرم$") and is_JoinChannel(msg) and CMD then
if redis:get("bot:ans"..msg.chat_id) == nil then
res = http.request('https://abolfazl.senatorhost.com/LuRaApi/marg.php')
sendMessage(msg.chat_id,msg.id, 1,res, 1, 'md')
else
res = http.request('https://abolfazl.senatorhost.com/Api/Marg.php')
sendMessage(msg.chat_id,msg.id, 1,res, 1, 'md')
end
elseif text:match("^لورا چطوری خودمو بکشم$") and is_JoinChannel(msg) and CMD then
if redis:get("bot:ans"..msg.chat_id) == nil then
res = http.request('https://abolfazl.senatorhost.com/LuRaApi/khodkoshi.php')
sendMessage(msg.chat_id,msg.id, 1,res, 1, 'md')
else
res = http.request('http://abolfazl.senatorhost.com/Api/Khodkoshi.php')
sendMessage(msg.chat_id,msg.id, 1,res, 1, 'md')
end
elseif text:match("^لورا بچم چیه$") and is_JoinChannel(msg) and CMD then
if redis:get("bot:ans"..msg.chat_id) == nil then
res = http.request('https://abolfazl.senatorhost.com/LuRaApi/bache.php')
sendMessage(msg.chat_id,msg.id, 1,res, 1, 'md')
else
res = http.request('https://abolfazl.senatorhost.com/Api/Bache.php')
sendMessage(msg.chat_id,msg.id, 1,res, 1, 'md')
end
elseif text:match("^لورا ماشینم چیه$") and is_JoinChannel(msg) and CMD then
if redis:get("bot:ans"..msg.chat_id) == nil then
res = http.request('https://abolfazl.senatorhost.com/LuRaApi/car.php')
sendMessage(msg.chat_id,msg.id, 1,res, 1, 'md')
else
res = http.request('https://abolfazl.senatorhost.com/Api/Mashin.php')
sendMessage(msg.chat_id,msg.id, 1,res, 1, 'md')
end
elseif text:match("^لورا$") and CMD then
if redis:get("bot:ans"..msg.chat_id) == nil then
res = http.request('https://abolfazl.senatorhost.com/LuRaApi/Robot.php')
sendMessage(msg.chat_id,msg.id, 1,res, 1, 'md')
else
res = http.request('https://abolfazl.senatorhost.com/Api/Lura.php')
sendMessage(msg.chat_id,msg.id, 1,res, 1, 'md')
end
elseif text:match("^اموجی (.*)$") and is_JoinChannel(msg) and CMD then
local text1000 = text:match("^اموجی (.*)$") 
local url ='http://2wap.org/usf/text_sm_gen/sm_gen.php?text='..text1000
local file = download_to_file(url,'Emoji.webp')
sendSticker(msg.chat_id, 0, file)
elseif text:match("^لورا عکس سگ بفرست$") and is_JoinChannel(msg) and CMD then 
local url = https.request('https://dog.ceo/api/breeds/image/random')
local jdat = jsons:decode(url)
local file = download_to_file(jdat.message,'dog.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لورا عکس گربه بفرست$") and is_JoinChannel(msg) and CMD then
local url = https.request("https://aws.random.cat/meow")
jdat = jsons:decode(url)
local file = download_to_file(jdat.file,'cat.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لورا عکس روباه بفرست$") and is_JoinChannel(msg) and CMD then
local rand = math.random(1,100)
local t = rand
if rand == t then 
rand = rand +1
local url ="https://randomfox.ca/images/"..rand.."jpg"
local file = download_to_file(url,'foxe.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
end
--------------------------------------------------
elseif text:match("^ریلود$") and is_sudo(msg)then
dofile('./bot.lua')
sendMessage(msg.chat_id, msg.id,1, "بات با موفقیت راه اندازی شد",1, "html")
elseif text:match("^lura$") then
local text = [[
♦️HI♦️

🍃I'm LuRa 

🎋Made By @botcollege 🔹

🔸Channel Team @botcollege 💯

💫Version : 4️⃣;

▫️ My Feature ▫️

1️⃣ Online 24 Hours/Weak ▪️

2️⃣ Funny Fature ▪️

3️⃣ Answer To All Person ▪️

4️⃣ Being Free ▪️

5️⃣ Everyone Can Import Me In Groups ▪️

➰Bot Project Language Is Lua ➰
]]
sendMessage(msg.chat_id,msg.id,1,text,1,"html")
end
if text:match("^لورا اومد$") and is_JoinChannel(msg) and CMD then
sendMessage(msg.chat_id,msg.id,1,"اوهوم اومدم",1,"html")
end
if text:match("^لورا راهنماییم کن$") and chat_type == 'supergroup' and CMD and is_JoinChannel(msg) then
if redis:get("bot:ans"..msg.chat_id) == nil then
local text2 = [[
▪️سلام گلم مرسی که داری ازمن استفاده میکنی🤪

♦️لطفا برای نمایش راهنمای مدیریتی بزن
`لورا دستورات مدیریتت چیه`

♦️و برای راهنمای فان ربات بزن
`لورا دستورات فانت چیه`
]]
sendMessage(msg.chat_id,msg.id,1,text2,1,"md")
else
local text2 = [[
▪️سلام کصخله مرسی ک میخای بگامت برای دیدن دستوراتم متن کیری زیرو بخون

♦️برای نمایش دستورات تخمیم ک مربوط ب ادمین کصلیسه دستور زیرو بزن
`لورا دستورات مدیریتت چیه`

♦️برای نمایش دستورات تخمی فانمم این کصشر زیرو بزن
`لورا دستورات فانت چیه`
]]
sendMessage(msg.chat_id,msg.id,1,text2,1,"md")

end
end
if text:match("^لورا دستورات مدیریتت چیه$") and chat_type == 'supergroup' and CMD and is_JoinChannel(msg) then
if redis:get("bot:ans"..msg.chat_id) == nil then
local text3 = [[
🍃 `setcmd [all - mod - owner]`
📍 تنظیم استفاده کننده ربات در گروه
🍂 All= همه اعضا
🍂 mod = صاحب گروه و مدیران
🍂 owner = فقط صاحب گروه
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا بخواب`
📍 برای غیرفعال کردن ربات درگروه
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂`لورا پاشو`
📍 برای فعال کردن ربات در گروه
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا اینو سنجاق کن`
📍 برای سنجاق کردن 
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا سنجاقو حذف کن`
📍 برای حذف سنجاق
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا لینک رو قفل کن`
📍 برای قفل تبلیغات لینکی
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا فوروارد رو قفل کن`
📍 برای قفل کردن فوروارد پیام
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا رباتو قفل کن`
📍 برای قفل کردن ادکردن ربات api
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا استیکر رو قفل کن`
📍 برای قفل کردن ارسال استیکر
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا قفل لینک رو بازکن`
📍 برای بازکردن قفل لینک
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا قفل فوروارد رو بازکن`
📍 برای بازکردن قفل فوروارد
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا قفل ربات رو بازکن`
📍 برای بازکردن قفل ربات
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا قفل استیکر رو بازکن`
📍 برای بازکردن قفل استیکر
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا دعوت اجباری رو فعال کن`
📍 برای فعال کردن دعوت اجباری
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا دعوت اجباری رو غیرفعال کن`
📍 برای غیرفعال کردن دعوت اجباری
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `تعداد دعوت [عدد]`
📍 برای مشخص کردن تعداد دعوت اجباری
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا مقامشو بکن [مقام موردنظر]`
📍 برای تنظیم مقام
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا مقامم چیه`
📍 برای دریافت مقام
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا مقام این چیه [ریپلای روفردموردنظر]`
📍 برای دریافت مقام فرد موردنظر
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا پیام پاک کن [عدد]`
📍 برای پاک کردن پیام های گروه بین 1تا100
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا پاکسازی دیلیت اکانتی ها`
📍 برای پاکسازی دلیت اکانتی ها
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا پاکسازی بلک لیست`
📍 برای پاکسازی لیست سیاه
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا رباتارو پاک کن`
📍 برای پاکسازی ربات های api
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا خوشامدگویی رو فعال کن`
📍 برای فعال کردن خوشامدگفتن به اعضای جدید
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا خوشامدگویی رو غیرفعال کن`
📍 برای غیرفعال کردن خوشامدگویی
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `تنظیم خوشامدگویی [متن]`
📍 برای تنظیم متن خوشامدگفتن
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
]]
sendMessage(msg.chat_id,msg.id,1,text3,1,"md")
else
local text31 = [[
🍃 `setcmd [all - mod - owner]`
📍 برا تنظیم اون کونیایی که میخان ازم استفاده کنن
🍂 All= همه جقیا
🍂 mod = صاحب کصلیس گپو مدیرای خایمالش
🍂 owner = فقط صاحب کصلیس گپ
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا بخواب`
📍 برای غیرفعال کردن من کصخل تو گپ کیریت
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂`لورا پاشو`
📍 برای فعال کردن من کصخل تو گپ کیریت
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا اینو سنجاق کن`
📍 پیام تخمیتو سنجاق میکنم
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا سنجاقو حذف کن`
📍 پیام تخمیتو از سنجاق درمیارم
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا لینک رو قفل کن`
📍 ارسال تخمی لینکو میبندم
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا فوروارد رو قفل کن`
📍 فوروارد رو میبندم که خارکصها فور نزنن
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا رباتو قفل کن`
📍 برای قفل کردن ربات های سگی api
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا استیکر رو قفل کن`
📍 برای قفل کردن کیری استیکر
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا قفل لینک رو بازکن`
📍 برای بازکردن تخمی لینک
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا قفل فوروارد رو بازکن`
📍 برای بازکردن قفل  کیری فوروارد
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا قفل ربات رو بازکن`
📍 برای بازکردن قفلای سگی api
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا قفل استیکر رو بازکن`
📍 برای بازکردن قفل استیکر کیری
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا دعوت اجباری رو فعال کن`
📍 برای گاییدن ممبرا تا اد بزنن تابتونن چت کنن
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا دعوت اجباری رو غیرفعال کن`
📍 برای غیرفعال کردن گاییدن ممبرا
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `تعداد دعوت [عدد]`
📍 برای مشخص کردن تعداد دعوتی ک باس اد بزنن تابگاییشون تموم شه
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا مقامشو بکن [مقام موردنظر]`
📍 برای تنظیم مقام کصاخیل
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا مقامم چیه`
📍 برای دریافت مقام جقیت
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا مقام این چیه [ریپلای روفردموردنظر]`
📍 برای دریافت مقام کصخل موردنظر
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا پیام پاک کن [عدد]`
📍 برای پاک کردن پیام های  کص گپ بین 1تا100
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا پاکسازی دیلیت اکانتی ها`
📍 برای پاکسازی کصخلایی ک دیل زدن ازتل
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا پاکسازی بلک لیست`
📍 برای پاکسازی لیست جقیایی ک سیک شدن ازگپ
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا رباتارو پاک کن`
📍 برای پاکسازی ربات های سگی api
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا خوشامدگویی رو فعال کن`
📍 برای فعال کردن کصگویی ب اعضای جدید وقتی میان
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا خوشامدگویی رو غیرفعال کن`
📍 برای غیرفعال کردن کص گویی ب اعضا جدید
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `تنظیم خوشامدگویی [متن]`
📍 برای تنظیم متن کصگویی
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖

]]
sendMessage(msg.chat_id,msg.id,1,text31,1,"md")
end
end
if text:match("^لورا دستورات فانت چیه$") and chat_type == 'supergroup' and CMD and is_JoinChannel(msg) then
if redis:get("bot:ans"..msg.chat_id) == nil then
local text2 = [[
🍃 `لورا فالمو بگیر`
📍 برای دریافت فال
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا جمله فازسنگین بفرست`
📍 برای دریافت متن فازسنگین
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃`لورا صلوات`
📍 برای صلوات فرستادن ربات
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `پرنسس [name]`
📍 برای ساخت استیکر اسم شما
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `شاه [name]`
📍 ساخت استیکر اسم شما
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا به نظرت شبیه کیم`
📍 برای این که شما شبیه کی هستید
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا هوای [اسم شهر]`
📍 برای دریافت آبوهوای شهر
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا من کیم`
📍 شما کی ربات هستید
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا به نظرت شغلم چیه`
📍 پیش بینی شغل شما در آینده
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا یه جوک بگو`
📍 برای دریافت جوک
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا یه چیستان بگو`
📍 برای دریافت چیستان
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا یچی بگو ندونم`
📍 برای دریافت دانستنی
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا اخبار بگو`
📍 برای دریافت اخبار روز
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا یه شعر بگو`
📍 برای دریافت شعر
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا زنم چطوریه`
📍 برای دریافت زن آیندتون
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `اموجی [name]`
📍 برای ساخت اموجی با متن موردنظر
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا وضعیت ترافیک [استان]`
📍 وضعیت ترافیکی استان موردنظر
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا وضعیت من`
📍 برای دریافت حال شما
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا ساعت چنده`
📍 برای دریافت ساعت
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `عنصر [name]`
📍 برای ساخت اسمتون باجدول مندلیوف
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `keepcalm v1 v2 v3`
📍 برای ساخت استیکر کیپ کالم
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا چطوری خودمو بکشم`
📍 برای دریافت راه خودکشی
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا مناسبت روز`
📍 دریافت مناسبت های روز
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا عکس بساز [متن]`
📍 ساخت عکس نوشته
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا نرخ ارز`
📍 برای دریافت نرخ ارز
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا شوهرم کیه`
📍 برای دخترا ببینن شوهر آیندشون کیه
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا بچم چیه`
📍 دریافت نوع جنسیت بچتون
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا بچه کجام`
📍 برای دریافت محل تولدتون
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا چطوری میمیرم`
📍 برای دریافت نوع مرگتون
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا اینو عکس کن`
📍 برای تبدیل استیکر به عکس
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا اینو استیکر کن`
📍 برای تبدیل عکس به استیکر
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا معنی [کلمه]`
📍 برای دریافت معنی کلمه ازلغتنامه
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا عکس رندوم بفرست`
📍 برای دریافت عکس های زیبا رندوم
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا عکس گربه بفرست`
📍 برای دریافت عکس گربه
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا عکس سگ بفرست`
📍 برای دریافت عکس سگ
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا بگوز`
📍 برای ارسال ویس بی ادبی گوز
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا بازی [سنگ|کاغذ|قیچی]`
📍 برای بازی کردن سنگ کاغذ قیچی با ربات
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لوگو [1تا80] name`
📍 برای ساخت لوگو اسم شما
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `lura`
📍 برای دریافت سازنده ربات
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖

]]
sendMessage(msg.chat_id,msg.id,1,text2,1,"md")
else
local text22 = [[
🍃 `لورا فالمو بگیر`
📍 برای دریافت سرنوشت کیریت
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا جمله فازسنگین بفرست`
📍 برای دریافت متن فازتخمی
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃`لورا صلوات`
📍 برای صلوات فرستادن ربات
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `پرنسس [name]`
📍 برای ساخت استیکر اسم کیریت
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `شاه [name]`
📍 ساخت استیکر اسم تخمیت
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا به نظرت شبیه کیم`
📍 برای این که ربات بگه چقد شبی کدوم کصخلی هسی
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا هوای [اسم شهر]`
📍 برای دریافت آبوهوای تخمی و وضعیت تخمی شهرت
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا من کیم`
📍 شما چه کسی  برا ربات هستید البت کیرشم نیسید
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا به نظرت شغلم چیه`
📍 ربات میگه تو آینده چه گوهی میخوری
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا یه جوک بگو`
📍 دریافت جکای تخمی
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا یه چیستان بگو`
📍 برای چیستانای کیری
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا یچی بگو ندونم`
📍 برای دریافت دانستنی و کیرشدن علمت
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا اخبار بگو`
📍 برای دریافت وضعیت اخبار تخمی روز
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا یه شعر بگو`
📍 برای دریافت شعرسکسی
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا زنم چطوریه`
📍 برای دریافت زن آیندتون که چقد جندس
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `اموجی [name]`
📍 برای ساخت اموجی با متن تخمیت
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا وضعیت ترافیک [استان]`
📍 وضعیت ترافیکی استان موردنظر که همیشه گاییده ترافیک
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا وضعیت من`
📍 برای دریافت حال شما که اونم تخمیست
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا ساعت چنده`
📍 برای دریافت ساعت و تایم جق زدنت
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `عنصر [name]`
📍 برای ساخت اسمتون باجدول عن دلیوف
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `keepcalm v1 v2 v3`
📍 برای ساخت استیکر کیپ کالم اروم باشو بکن
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا چطوری خودمو بکشم`
📍 برای دریافت راه هایی ک خودتو بگایی
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا مناسبت روز`
📍 دریافت مناسبت های روز های مملکت کیری
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا عکس بساز [متن]`
📍 ساخت عکس نوشته کیری
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا نرخ ارز`
📍 برای دریافت نرخ ارز که میگاد با بالاپایین شدنش
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا شوهرم کیه`
📍 برای دخترا ببینن شوهر آیندشون کیه
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا بچم چیه`
📍 دریافت نوع جنسیت بچتون
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا بچه کجام`
📍 برای دریافت محل تولدتون
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا چطوری میمیرم`
📍 برای دریافت نوع مرگتون
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا اینو عکس کن`
📍 برای تبدیل استیکر به عکس
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا اینو استیکر کن`
📍 برای تبدیل عکس به استیکر
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا معنی [کلمه]`
📍 برای دریافت معنی کلمه ازلغتنامه کصخل
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا عکس رندوم بفرست`
📍 برای دریافت عکس های تخمی رندوم
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا عکس گربه بفرست`
📍 برای دریافت عکس گربه درحال جق
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا عکس سگ بفرست`
📍 برای دریافت عکس سگ درحال جق
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لورا بگوز`
📍 برای شنیدن گوزم
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `لورا بازی [سنگ|کاغذ|قیچی]`
📍 برای گوبازی سنگ کاغذقیچی تخمی
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍂 `لوگو [1تا80] name`
📍 برای ساخت لوگوکیری از اسم تخمی
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
🍃 `lura`
📍 دریافت کصخلی ک منوساخته کیه
❖❖❖❖❖❖❖❖❖❖❖❖❖❖❖
]]
sendMessage(msg.chat_id,msg.id,1,text22,1,"md")
end
end
--if text:match("^فوروارد پیام$") and tonumber(reply_id) > 0 and is_sudo(msg)then
if text:match("^ارسال پیام (.*)$") and is_sudo(msg) then
local input = text:match("^ارسال پیام (.*)$")
local gplists = redis:smembers("grouplist")
for k,v in pairs(gplists) do
sendMessage(v,0,1,input,1,"html")
end
end
if text:match("^ارسال پیوی (.*)$") and is_sudo(msg) then
local input = text:match("^ارسال پیوی (.*)$")
local pvlist = redis:smembers("pvList")
for k,v in pairs(pvlist) do
sendMessage(v,0,1,input,1,"html")
end
end
if text:match("^فور$") and msg.reply_to_message_id then
list= redis:smembers("grouplist")
for i=1,#list do
Forwarded(list[i],msg.chat_id,msg.reply_to_message_id,1)
end
end
if text:match("^آمار ربات$") and is_admin(msg)then
local gplists = redis:smembers("grouplist")
for k,v in pairs(gplists) do
text = "آمار ربات تا کنون :["..k.."] گروه میباشد"
end
local pvlist = redis:smembers("pvList")
for k,v in pairs(pvlist) do
textd = "آمار ربات تا کنون :["..k.."] پیوی میباشد"
end
sendMessage(msg.chat_id, msg.id, 1, text.."\n"..textd, 1, "html")
end
if text:match("لورا من کیم ها؟") and is_sudo(msg) then
sendMessage(msg.chat_id,msg.id,1,"تو سازنده منی 😍 مرسی که هستی سازنده من",1,"md")
end
-- Monasebat
if text:match("^لورا مناسبت روز$") and is_JoinChannel(msg) and CMD then
local url = http.request('http://api.lorddeveloper.ir/occasion/')
local jdat = jsons:decode(url)
sendMessage(msg.chat_id,msg.id, 1,"`مناسبت های امروز` \n\n`مناسبت های میلادی:`\n"..jdat.miladi.."\n`مناسبت های شمسی:`\n"..jdat.shamsi.."\n`مناسبت های قمری:`\n"..jdat.ghamari, 1, 'md')
end
-- Arz
if text:match("^لورا نرخ ارز$") and is_JoinChannel(msg) and CMD then
local url = https.request("https://api.world-team.ir/money/")
local jdat = jsons:decode(url)
sendMessage(msg.chat_id,msg.id,1,"نرخ ارز\n💰قیمت خرید دلار:"..jdat.buy_usd.price.."\n💰قیمت فروش دلار:"..jdat.sell_usd.price.."\n〰️〰️〰️〰️〰️〰️\n💰قیمت خرید یورو :"..jdat.buy_eur.price.."\n💰قیمت فروش یورو : "..jdat.sell_eur.price.."\n@botcollege",1,'md')
end
-- Traffick

if text:match("^لورا وضعیت ترافیک (.*)$") and is_JoinChannel(msg) and CMD then
local cytr = text:match("^لورا وضعیت ترافیک (.*)$")
local function CheckCity(city)
if not city then return end
local cities={
Fa={"تهران","آذربایجان شرقی","آذربایجان غربی","اردبیل","اصفهان","البرز","ایلام","بوشهر","چهارمحال و بختیاری","خراسان جنوبی","خوزستان","زنجان","سمنان","سیستان و بلوچستان","شیراز","قزوین","قم","کردستان","کرمان","کرمانشاه","کهگیلویه و بویراحمد","گلستان","گیلان","گلستان","لرستان","مازندران","مرکزی","هرمزگان","همدان","یزد"},
En={"Tehran","AzarbayjanSharghi","AzarbayjanGharbi","Ardebil","Esfehan","Alborz","Ilam","Boshehr","Chaharmahalbakhtiari","KhorasanJonoobi","Khozestan","Zanjan","Semnan","SistanBalochestan","Fars","Ghazvin","Qom","Kordestan","Kerman","KermanShah","KohkilooyehVaBoyerAhmad","Golestan","Gilan","Lorestan","Mazandaran","Markazi","Hormozgan","Hamedan","Yazd"}}
for k,v in pairs(cities.Fa) do
if city == v then
return cities.En[k]
end
end
return false
end
local result = CheckCity(cytr)
if result then
local Traffick = "https://images.141.ir/Province/"..result..".jpg"
local file = download_to_file(Traffick,'Traffick.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
else
sendMessage(msg.chat_id, 0, 1,"💩 مکان اشتباهه باو", 1, "html")
end
end

-- Vasiat
if text:match("^لورا وضعیت من$") and is_JoinChannel(msg) and CMD then
if redis:get("bot:ans"..msg.chat_id) == nil then
local datebase = {"درحال شادی","ناراحت از زندگی","خیلی مصمم برای انجام کار","اماده انجام وظیفه","احتمالا یخورده خوابت میاد","خسته مثل دشمن😂","اماده خوردن چن تا ادم ازگشنگی😂😝😝"}
local num1= math.random (1,100);local num2= math.random (1,100);local num3= math.random (1,100);local num4= math.random (1,100);local num5= math.random (1,100);local num6= math.random (1,100);local num7= math.random (1,100);local num8= math.random (1,100)
local text = "وضعیت شما به صورت زیر است\n بی حوصلگی : "..num1.."%\nخوشحالی : "..num2.."%\nافسردگی : "..num3.."%\nامادگی جسمانی : "..num4.."%\nدرصد سلامتی : "..num5.."%\nتنبلی : "..num6.."%\nبی خیالی : "..num6.."%\nوضعیت روحی شما : "..datebase[math.random(#datebase)]
sendMessage(msg.chat_id, msg.id, 1, text, 1, "html")
else
local datebase = {"درحال جق زدن","ناراحت ازین که تایم جقتو گرفتن ازت","خیلی مصممی که جق بزنی ولی مکان نداری","اماده انجام جق زدن","احتمالا یخورده جقت میاد","خسته مثل کیربعد جق","اماده خوردن کلی موز چون ازبس جق زدی کمترخالیه"}
local num1= math.random (1,100);local num2= math.random (1,100);local num3= math.random (1,100);local num4= math.random (1,100);local num5= math.random (1,100);local num6= math.random (1,100);local num7= math.random (1,100);local num8= math.random (1,100)
local text = "وضعیت شما به صورت زیر است\n کصخلی : "..num1.."%\nجقی بودن : "..num2.."%\nکونی بودن : "..num3.."%\nشق بودن کیرت : "..num4.."%\nسگ بودن : "..num5.."%\nگشادبودنت : "..num6.."%\nبه تخمت بودن : "..num6.."%\nوضعیت جقی شما: "..datebase[math.random(#datebase)]
sendMessage(msg.chat_id, msg.id, 1, text, 1, "html")
end
end
------------------------------
if text:match("لورا عکس بساز (.*)") and CMD and is_JoinChannel(msg) then
input = text:match("لورا عکس بساز (.*)")
local url = "https://world-team.ir/api/logo/?bg=http://up2www.com/uploads/f645photo-2018-10-04-16-27-02.jpg&fsize=50&ht=100&wt=20&RO=1&color=white&lang=en&text="..input
local file = download_to_file(url,'logo.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
end
if text:match("^لوگو1 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو1 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=259&text="..input
local file = download_to_file(url,'logo1.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو2 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو2 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=258&text="..input
local file = download_to_file(url,'logo2.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو3 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو3 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=251&text="..input
local file = download_to_file(url,'logo3.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو4 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو4 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=248&text="..input
local file = download_to_file(url,'logo4.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو5 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو5 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=247&text="..input
local file = download_to_file(url,'logo5.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو6 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو6 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=246&text="..input
local file = download_to_file(url,'logo6.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو7 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو7 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=245&text="..input
local file = download_to_file(url,'logo7.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو8 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو8 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=215&text="..input
local file = download_to_file(url,'logo8.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو9 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو9 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=213&text="..input
local file = download_to_file(url,'logo9.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو10 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو10 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=212&text="..input
local file = download_to_file(url,'logo10.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو11 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو11 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=210&text="..input
local file = download_to_file(url,'logo11.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو12 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو12 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=208&text="..input
local file = download_to_file(url,'logo12.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو13 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو13 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=117&text="..input
local file = download_to_file(url,'logo13.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو14 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو14 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=206&text="..input
local file = download_to_file(url,'logo14.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو15 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو15 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=204&text="..input
local file = download_to_file(url,'logo15.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو16 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو16 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=200&text="..input
local file = download_to_file(url,'logo16.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو17 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو17 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=171&text="..input
local file = download_to_file(url,'logo17.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو18 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو18 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=194&text="..input
local file = download_to_file(url,'logo18.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو19 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو19 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=188&text="..input
local file = download_to_file(url,'logo19.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو20 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو20 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=187&text="..input
local file = download_to_file(url,'logo20.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو21 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو21 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=186&text="..input
local file = download_to_file(url,'logo21.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو22 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو22 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=184&text="..input
local file = download_to_file(url,'logo22.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو23 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو23 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=183&text="..input
local file = download_to_file(url,'logo23.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو24 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو24 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=181&text="..input
local file = download_to_file(url,'logo24.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو25 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو25 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=180&text="..input
local file = download_to_file(url,'logo25.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو26 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو26 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=179&text="..input
local file = download_to_file(url,'logo26.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو27 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو27 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=178&text="..input
local file = download_to_file(url,'logo27.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو28 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو28 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=158&text="..input
local file = download_to_file(url,'logo28.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو29 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو29 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=165&text="..input
local file = download_to_file(url,'logo29.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو30 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو30 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=168&text="..input
local file = download_to_file(url,'logo30.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو31 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو31 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=109&text="..input
local file = download_to_file(url,'logo31.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو32 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو32 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=164&text="..input
local file = download_to_file(url,'logo32.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو33 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو33 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=162&text="..input
local file = download_to_file(url,'logo33.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو34 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو34 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=160&text="..input
local file = download_to_file(url,'logo34.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو35 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو35 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=157&text="..input
local file = download_to_file(url,'logo35.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو36 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو36 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=154&text="..input
local file = download_to_file(url,'logo36.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو37 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو37 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=153&text="..input
local file = download_to_file(url,'logo37.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو38 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو38 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=147&text="..input
local file = download_to_file(url,'logo38.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو39 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو39 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=146&text="..input
local file = download_to_file(url,'logo39.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو40 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو40 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=140&text="..input
local file = download_to_file(url,'logo40.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو41 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو41 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=139&text="..input
local file = download_to_file(url,'logo41.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو42 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو42 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=126&text="..input
local file = download_to_file(url,'logo42.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو43 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو43 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=122&text="..input
local file = download_to_file(url,'logo43.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو44 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو44 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=112&text="..input
local file = download_to_file(url,'logo44.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو45 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو45 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=116&text="..input
local file = download_to_file(url,'logo45.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو46 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو46 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=108&text="..input
local file = download_to_file(url,'logo46.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو47 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو47 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=107&text="..input
local file = download_to_file(url,'logo47.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو48 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو48 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=102&text="..input
local file = download_to_file(url,'logo48.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو49 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو49 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=359&text="..input
local file = download_to_file(url,'logo49.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو50 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو50 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=358&text="..input
local file = download_to_file(url,'logo50.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو51 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو51 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=357&text="..input
local file = download_to_file(url,'logo51.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو52 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو52 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=356&text="..input
local file = download_to_file(url,'logo52.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو53 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو53 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=71&text="..input
local file = download_to_file(url,'logo53.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو54 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو54 (.*)")
local url = "http://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=343&text="..input
local file = download_to_file(url,'logo54.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو55 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو55 (.*)")
local url = "https://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=342&text="..input
local file = download_to_file(url,'logo55.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو56 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو56 (.*)")
local url = "https://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=340&text="..input
local file = download_to_file(url,'logo56.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو56 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو56 (.*)")
local url = "https://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=340&text="..input
local file = download_to_file(url,'logo56.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو57 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو57 (.*)")
local url = "https://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=339&text="..input
local file = download_to_file(url,'logo57.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو58 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو58 (.*)")
local url = "https://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=329&text="..input
local file = download_to_file(url,'logo58.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو59 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو59 (.*)")
local url = "https://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=307&text="..input
local file = download_to_file(url,'logo59.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو60 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو60 (.*)")
local url = "https://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=305&text="..input
local file = download_to_file(url,'logo60.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو61 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو61 (.*)")
local url = "https://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=101&text="..input
local file = download_to_file(url,'logo61.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو62 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو62 (.*)")
local url = "https://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=97&text="..input
local file = download_to_file(url,'logo62.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو63 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو63 (.*)")
local url = "https://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=96&text="..input
local file = download_to_file(url,'logo63.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو64 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو64 (.*)")
local url = "https://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=93&text="..input
local file = download_to_file(url,'logo64.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو65 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو65 (.*)")
local url = "https://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=92&text="..input
local file = download_to_file(url,'logo65.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو66 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو66 (.*)")
local url = "https://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=91&text="..input
local file = download_to_file(url,'logo66.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو67 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو67 (.*)")
local url = "https://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=90&text="..input
local file = download_to_file(url,'logo67.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو68 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو68 (.*)")
local url = "https://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=88&text="..input
local file = download_to_file(url,'logo68.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو69 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو69 (.*)")
local url = "https://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=86&text="..input
local file = download_to_file(url,'logo69.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو70 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو70 (.*)")
local url = "https://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=85&text="..input
local file = download_to_file(url,'logo70.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو71 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو71 (.*)")
local url = "https://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=84&text="..input
local file = download_to_file(url,'logo71.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو72 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو72 (.*)")
local url = "https://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=83&text="..input
local file = download_to_file(url,'logo72.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو73 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو73 (.*)")
local url = "https://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=81&text="..input
local file = download_to_file(url,'logo73.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو74 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو74 (.*)")
local url = "https://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=80&text="..input
local file = download_to_file(url,'logo74.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو75 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو75 (.*)")
local url = "https://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=79&text="..input
local file = download_to_file(url,'logo75.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو76 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو76 (.*)")
local url = "https://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=76&text="..input
local file = download_to_file(url,'logo76.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو77 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو77 (.*)")
local url = "https://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=75&text="..input
local file = download_to_file(url,'logo77.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو78 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو78 (.*)")
local url = "https://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=74&text="..input
local file = download_to_file(url,'logo78.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو79 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو79 (.*)")
local url = "https://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=73&text="..input
local file = download_to_file(url,'logo79.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو80 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو80 (.*)")
local url = "https://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=72&text="..input
local file = download_to_file(url,'logo80.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو81 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو81 (.*)")
local url = "https://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=69&text="..input
local file = download_to_file(url,'logo81.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو82 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو82 (.*)")
local url = "https://aliaz.titan-hosting.ir/mafia_kings/api.php/?type199=&text="..input
local file = download_to_file(url,'logo82.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو83 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو83 (.*)")
local url = "https://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=68&text="..input
local file = download_to_file(url,'logo83.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو84 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو84 (.*)")
local url = "https://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=63&text="..input
local file = download_to_file(url,'logo84.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو85 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو85 (.*)")
local url = "https://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=62&text="..input
local file = download_to_file(url,'logo85.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو86 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو86 (.*)")
local url = "https://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=61&text="..input
local file = download_to_file(url,'logo86.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو87 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو87 (.*)")
local url = "https://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=59&text="..input
local file = download_to_file(url,'logo87.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو88 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو88 (.*)")
local url = "https://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=18&text="..input
local file = download_to_file(url,'logo88.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو89 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو89 (.*)")
local url = "https://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=365&text="..input
local file = download_to_file(url,'logo89.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو90 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو90 (.*)")
local url = "https://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=368&text="..input
local file = download_to_file(url,'logo90.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو91 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو91 (.*)")
local url = "https://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=369&text="..input
local file = download_to_file(url,'logo91.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو92 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو92 (.*)")
local url = "https://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=372&text="..input
local file = download_to_file(url,'logo92.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
elseif text:match("^لوگو93 (.*)$") and is_JoinChannel(msg) and CMD then
input = text:match("لوگو93 (.*)")
local url = "https://aliaz.titan-hosting.ir/mafia_kings/api.php/?type=373&text="..input
local file = download_to_file(url,'logo93.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)

end
--KeepCalm

if text:match("^keepcalm (.*) (.*) (.*)$")and CMD and is_JoinChannel(msg) then
local input = {
string.match(text, "keepcalm (.*) (.*) (.*)$")
} 
local url ="http://www.keepcalmstudio.com/-/p.php?t=%EE%BB%AA%0D%0AKEEP%0D%0ACALM%0D%0A"..input[1].."%0D%0A"..input[2].."%0D%0A"..input[3].."&bc=00000&tc=FFFFFF&cc=FFFFFF&uc=true&ts=true&ff=PNG&w=500&ps=sq"
local file = download_to_file(url,"Keep.webp")
sendSticker(msg.chat_id, 0, file)
end

--Onsoer
if text:match("^عنصر (.*)$")and CMD and is_JoinChannel(msg) then
local input = {
string.match(text, "عنصر (.*)$")
} 
local url = "http://www.myfunstudio.com/-/p.php?d=pt&t=" ..input[1].. "&c_bc=FFFFFF&a=r&ag=true&an=true&aw=true&cs=weird&e=false&f=t&n=true&ts=true&ff=PNG&w=1080"
local file = download_to_file(url,"Keep.webp")
sendSticker(msg.chat_id, 0, file)
end
--Clean MSG

if text:match("^لورا پیام پاک کن (.*)$") and is_JoinChannel(msg) and is_mod(msg) then
local limit = text:match("^لورا پیام پاک کن (.*)$")
if tonumber(limit) then
if tonumber(limit) > 100 then
sendMessage(msg.chat_id, msg.id, 1, "لطفا از اعداد بین [1-100] استفاده کنیم!", 1, "html")
else
local function cb(arg,data)
if data.messages == 0 then
return false
end
if data.messages then
for k,v in pairs(data.messages) do
deleteMessages(msg.chat_id,{[0] =v.id})
end
sendMessage(msg.chat_id, msg.id, 1, "انجام شد", 1, "html")
end
end
getChatHistory(msg.chat_id,0, 0,  limit + 1,cb)
end
end
end


-------------------------------------------------------------------------
--[[
if text:match("^tleague$") and is_JoinChannel(msg) and CMD then
local url = 'http://www.top90.ir/iran/persian-gulf-league'
local res,code = http.request(url)
res = res:gsub('.*<table class="lt show">',''):gsub('</table>.*',''):gsub('&ndash;','')
local text = ''
local i = 1
for teams in res:gmatch('<td class="ltid">[^<]*</td><td class="ltn">[^<]*</td><td class="ltg">[^<]*</td><td class="ltw">[^<]*</td><td class="ltd">[^<]*</td><td class="ltl">[^<]*</td><td class="ltgf">[^<]*</td><td class="ltga">[^<]*</td><td class="ltgd" dir="ltr">[^<]*</td><td class="ltp">[^<]*</td>') do
local tinfo = {teams:match('<td class="ltid">([^<]*)</td><td class="ltn">([^<]*)</td><td class="ltg">([^<]*)</td><td class="ltw">([^<]*)</td><td class="ltd">([^<]*)</td><td class="ltl">([^<]*)</td><td class="ltgf">([^<]*)</td><td class="ltga">([^<]*)</td><td class="ltgd" dir="ltr">([^<]*)</td><td class="ltp">([^<]*)</td>')}
text = text..make_text(lang[ln].leauge.table,i,tinfo[2],tinfo[10])..'\n\n'
i = i + 1
end
text = text..lang[ln].leauge.table_h
sendMessage(msg.chat_id, msg.id, 1,text, 1, "html")
elseif text:match("^teaminfo (.*)$")and is_JoinChannel(msg) and CMD then
local input =text:match("^teaminfo (.*)$")
local url = 'http://www.top90.ir/iran/persian-gulf-league'
local res,code = http.request(url)
res = res:gsub('.*<table class="lt show">',''):gsub('</table>.*',''):gsub('&ndash;','')
local text = ''
local i = 1
for teams in res:gmatch('<td class="ltid">[^<]*</td><td class="ltn">[^<]*</td><td class="ltg">[^<]*</td><td class="ltw">[^<]*</td><td class="ltd">[^<]*</td><td class="ltl">[^<]*</td><td class="ltgf">[^<]*</td><td class="ltga">[^<]*</td><td class="ltgd" dir="ltr">[^<]*</td><td class="ltp">[^<]*</td>') do
if i == tonumber(input) then
local tinfo = {teams:match('<td class="ltid">([^<]*)</td><td class="ltn">([^<]*)</td><td class="ltg">([^<]*)</td><td class="ltw">([^<]*)</td><td class="ltd">([^<]*)</td><td class="ltl">([^<]*)</td><td class="ltgf">([^<]*)</td><td class="ltga">([^<]*)</td><td class="ltgd" dir="ltr">([^<]*)</td><td class="ltp">([^<]*)</td>')}
text = text..make_text(lang[ln].leauge.tinfo_1,tinfo[2],tinfo[3],tinfo[10],tinfo[4],tinfo[5])..make_text(lang[ln].leauge.tinfo_2,tinfo[6],tinfo[7],tinfo[8],tinfo[9])
end
i = i + 1
end
if text == '' then
text = lang[ln].leauge.tinfo_nf
end
sendMessage(msg.chat_id, msg.id, 1,text, 1, "html")
end

]]
-------------------------------------------------------------------------
--[[if text:match("^لورا معنی (.*)$") and CMD and is_JoinChannel(msg) then
local input = text:match("^لورا معنی (.*)$")
local url =http.request("http://api.vajehyab.com/v3/search?token=61667.klMWuQcHR99sQjntO5D1DoF4AaWQwcdRyZN3P0LG&q="..input.."&type=exact&filter=moein")
local res = jsons:decode(url)
if res.data.num_found == 0 then
sendMessage(msg.chat_id, msg.id, 1,"کلمه وجود ندارد", 1, "md")
else
local text = "کلمه اولیه : "..input.."\n معنی: \n"..res.data.results[1].text
sendMessage(msg.chat_id, msg.id, 1,text, 1, "md")
end
end
]]
------------------------------------------------------------------------
if text:match("^لورا عکس رندوم بفرست$") and CMD and is_JoinChannel(msg) then
local rand = math.random(1,700)
local arr = rand
if arr == rand then
rand = rand + 1 
local url = "https://picsum.photos/1024/1024/?image="..rand
local file = download_to_file(url,'rand.jpg')
sendPhoto(msg.chat_id, 0,file, config.channel_id)
end
end
-------------------------------------------------------------------------
if text:match("^لورا مقامشو بکن (.*)$") and tonumber(reply_id) > 0 and is_JoinChannel(msg) and is_mod(msg) then
local test = text:match("^لورا مقامشو بکن (.*)$")
function idreply(extra, result)
redis:set("setrank"..result.sender_user_id,test)
if redis:get("bot:ans"..msg.chat_id) == nil then
sendMessage(msg.chat_id, msg.id, 1," حله مقامشو تنظیم کردم به["..test.."] خیالت تخت.", 1, "html")
else
sendMessage(msg.chat_id, msg.id, 1," حله مقامشو این کصخل پلشتو  کردم["..test.."] خیالت تخت.", 1, "html")
end
end
getMessage(msg.chat_id, reply_id, idreply)
end
if text:match("^لورا مقامم چیه$") and tonumber(reply_id) == 0 and is_JoinChannel(msg) and CMD then
if redis:get("setrank"..msg.sender_user_id) then
rankget1 = redis:get("setrank"..msg.sender_user_id)
else
if redis:get("bot:ans"..msg.chat_id) == nil then
rankget1 = "مقام نداری والا!"
else
rankget1 ="تو کیرم نداری اون که مقامه والا!"
end
end
sendMessage(msg.chat_id, msg.id, 1, rankget1, 1, "html")
elseif text:match("^لورا مقام این چیه$") and tonumber(reply_id) > 0 and is_JoinChannel(msg) and CMD then
function idreply(extra, result)
if redis:get("setrank"..result.sender_user_id) then
rankget1 = redis:get("setrank"..result.sender_user_id)
else
if redis:get("bot:ans"..msg.chat_id) == nil then
rankget1 = "مقام نداره والا!"
else
rankget1 = "اون کصخل کیرم نداره اون که مقامه والا!"
end
end
sendMessage(msg.chat_id, msg.id, 1, rankget1, 1, "html")
end
getMessage(msg.chat_id, reply_id, idreply)
end
end
-------------------------------------------------------------------------
if text:match("^لورا ساعت چنده$") and is_JoinChannel(msg) and CMD then
local url , res = https.request('https://enigma-dev.ir/api/time/')
if res ~= 200 then
sendMessage(msg.chat_id, 0, 1,"مشکلی رخ داده", 1, "html")
end
local jdat = jsons:decode(url)
text = "🗓 امروز : "..jdat.FaDate.WordTwo.."\n⏰ ساعت : "..jdat.FaTime.Number.."\n".."\n🗓*Today* : *"..jdat.EnDate.WordOne.."*".."\n⏰ *Time* : *"..jdat.EnTime.Number.."*"
sendMessage(msg.chat_id, 0, 1,text, 1, "md")
end
if text:match("^لورا اینو سنجاق کن$") and tonumber(reply_id) > 0 and is_mod(msg) and is_JoinChannel(msg)then
function pin_msg(extra, result)
pinChannelMessage(msg.chat_id, result.id)
if redis:get("bot:ans"..msg.chat_id) == nil then
sendMessage(msg.chat_id, msg.id, 1, "انجام دادم سنجاق شد حله؟", 1, "html")
else
sendMessage(msg.chat_id, msg.id, 1, "خا باو گاییدی سنجاقش کردم", 1, "html")
end
end
getMessage(msg.chat_id, reply_id, pin_msg)
end
if text:match("^لورا سنجاقو حذف کن$") and is_mod(msg) and is_JoinChannel(msg) then
if redis:get("bot:ans"..msg.chat_id) == nil then
sendMessage(msg.chat_id, msg.id, 1, "چشم سنجاق برداشته شد عزیز", 1, "html")
else
sendMessage(msg.chat_id, msg.id, 1, "ی مین زخم نکن الان سنجاقو برمیدارم", 1, "html")
end
unpinChannelMessage(msg.chat_id)
end

if text:match("^لورا اینو عکس کن$")  and tonumber(reply_id) > 0 and CMD and is_JoinChannel(msg) then
function tophoto(extra, result)
if result.content._ == 'messageSticker' then
print(result.content.sticker.sticker.path)
sendPhoto(msg.chat_id, 0,result.content.sticker.sticker.path, config.channel_id)
end
end
getMessage(msg.chat_id, reply_id, tophoto)
end
if text:match("^لورا اینو استیکر کن$")  and tonumber(reply_id) > 0 and CMD and is_JoinChannel(msg) then
function tophoto(extra, result)
if result.content._ == 'messagePhoto' then
local getstickerphoto = result.content.photo.sizes
for k,v in pairs(getstickerphoto) do
if v.type == "x" then
photostik = v.photo.path
print(photostik)
end
end
sendSticker(msg.chat_id, 0, photostik)
end
end
getMessage(msg.chat_id, reply_id, tophoto)
end
-----------------Lock Command---------------
-----Checker
--Link
if not is_mod(msg) then
if text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]/") or text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Dd][Oo][Gg]/") or text:match("[Tt].[Mm][Ee]/") or text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]/") then
if redis:get("sg:link"..msg.chat_id) == "lock" then
deleteMessages(msg.chat_id, {[0] = msg.id})
end
end

--Api Bot

if redis:get("sg:bot"..msg.chat_id) == "lock" then
if msg.adding_user then
function addingusers(extra,result)
if result.type._ == "userTypeBot"  then 
kickuser(msg.chat_id, result.id)
end
end
getUser(msg.adding_user,addingusers)
end
end
--Forward

if msg.forward_info then
if redis:get("sg:forward"..msg.chat_id) == "lock" then
deleteMessages(msg.chat_id, {[0] = msg.id})
end
end

--Sticker

if msg.content._ == 'messageSticker' then
if redis:get("sg:sticker"..msg.chat_id) == "lock" then
deleteMessages(msg.chat_id, {[0] = msg.id})
end
end
end

--Force Join 
if not is_mod(msg) then
if (data._ == "updateNewMessage") or (data._ == "updateNewChannelMessage") or (data._== "updateMessageEdited") then
if redis:get("sg:joinchat"..msg.chat_id) == "lock" then
if not redis:get("setjoin"..msg.chat_id) then
MAX_MEMBER = 2
else
MAX_MEMBER = redis:get("setjoin"..msg.chat_id)
end
local memeber_addings = redis:get("chat_member"..msg.chat_id.."user_id"..msg.sender_user_id)
local gettext = redis:get("userset"..msg.chat_id.."user_id"..msg.sender_user_id)
if redis:get("chat_member"..msg.chat_id.."user_id"..msg.sender_user_id) == "ok" then
return false
end
if tonumber(memeber_addings) ~= tonumber(MAX_MEMBER) then
if not gettext or gettext == "0" then
local function getnames(extra,result)
local name = result.first_name
--if redis:get("bot:ans"..msg.chat_id) == nil then
sendMention(msg.chat_id, user_id, 0, "دوست گلم: ( "..name.." )\nلطفا ["..MAX_MEMBER.."] ممبر به گروه اضافه کن تابهت  اجازه چت در گروه رو بدم  باشه؟ افرین", 9,utf8.len(name))
--else
--sendMention(msg.chat_id, user_id, 0, "کصخل عزیز: ( "..name.." )\nلطفا ["..MAX_MEMBER.."] ممبر به گروه اضافه کن تابهت  گوخوری تو گپو بت بدم باشه؟ افرین حالا ادتو بزن کصخل", 9,utf8.len(name))
--end
redis:set("userset"..msg.chat_id.."user_id"..msg.sender_user_id , "1")
end
getUser(user_id,getnames)
deleteMessages(msg.chat_id, {[0] = msg.id})
elseif gettext == "1" then
deleteMessages(msg.chat_id, {[0] = msg.id})
end
end
end
end
end


--End Of Checker

--Command Lock

if text:match("^لورا لینک رو قفل کن$") and is_mod(msg) and is_JoinChannel(msg) then
redis:set("sg:link"..msg.chat_id,"lock")
if redis:get("bot:ans"..msg.chat_id) == nil then
sendMessage(msg.chat_id, msg.id, 1, "باش قفل لینک رو فعال کردم", 1, "html")
else
sendMessage(msg.chat_id, msg.id, 1, "خا باو کصخل قفل لینک فعال کردمش کونده خان", 1, "html")
end
elseif text:match("^لورا فوروارد رو قفل کن$")and is_mod(msg) and is_JoinChannel(msg) then
redis:set("sg:forward"..msg.chat_id,"lock")
if redis:get("bot:ans"..msg.chat_id) == nil then
sendMessage(msg.chat_id, msg.id, 1, "باش قفل فوروارد رو فعال کردم", 1, "html")
else
sendMessage(msg.chat_id, msg.id, 1, "خا باو کصخل قفل  فوروارد رو  فعال کردمش کونده خان", 1, "html")
end
elseif text:match("^لورا رباتو قفل کن$") and is_mod(msg) and is_JoinChannel(msg) then
redis:set("sg:bot"..msg.chat_id,"lock")
if redis:get("bot:ans"..msg.chat_id) == nil then
sendMessage(msg.chat_id, msg.id, 1, "باش اگر کسی ربات اد کنه رباته رو پاک میکنم", 1, "html")
else
sendMessage(msg.chat_id, msg.id, 1, "خا باو کصخل قفل ربات فعال کردمش کونده خان", 1, "html")
end
elseif text:match("^لورا استیکر رو قفل کن$") and is_mod(msg)and is_JoinChannel(msg) then
redis:set("sg:sticker"..msg.chat_id,"lock")
if redis:get("bot:ans"..msg.chat_id) == nil then
sendMessage(msg.chat_id, msg.id, 1, "باش قفل استیکر رو فعال کردم", 1, "html")
else
sendMessage(msg.chat_id, msg.id, 1, "خا باو کصخل قفل  استیکر تخمی رو فعال کردمش کونده خان", 1, "html")
end
end

--Command Open

if text:match("^لورا قفل لینک رو بازکن$") and is_mod(msg)and is_JoinChannel(msg)then
redis:del("sg:link"..msg.chat_id)
if redis:get("bot:ans"..msg.chat_id) == nil then
sendMessage(msg.chat_id, msg.id, 1, "باش قفل لینک بازشد", 1, "html")
else
sendMessage(msg.chat_id, msg.id, 1, "خا زخم نکن الان قفل لینکو بازکردم", 1, "html")
end
elseif text:match("^لورا قفل فوروارد رو بازکن$") and is_mod(msg)and is_JoinChannel(msg)then
redis:del("sg:forward"..msg.chat_id)
if redis:get("bot:ans"..msg.chat_id) == nil then
sendMessage(msg.chat_id, msg.id, 1, "باش قفل فوروارد بازشد", 1, "html")
else
sendMessage(msg.chat_id, msg.id, 1, "خا باو زخم نکن الان قفل فوروارد رو بازکردم", 1, "html")
end
elseif text:match("^لورا قفل ربات رو بازکن$") and is_mod(msg)and is_JoinChannel(msg)then
redis:del("sg:bot"..msg.chat_id)
if redis:get("bot:ans"..msg.chat_id) == nil then
sendMessage(msg.chat_id, msg.id, 1, "باش ازین به بعد هرکی ربات اد کنه رباتشو پاک نمیکنم", 1, "html")
else
sendMessage(msg.chat_id, msg.id, 1, "خا باو زخم نکن قفل ربات رو بازکردم الان", 1, "html")
end
elseif text:match("^لورا قفل استیکر رو بازکن$") and is_mod(msg)and is_JoinChannel(msg)then
redis:del("sg:sticker"..msg.chat_id)
if redis:get("bot:ans"..msg.chat_id) == nil then
sendMessage(msg.chat_id, msg.id, 1,"باش قفل استیکر بازشد", 1, "html")
else
sendMessage(msg.chat_id, msg.id, 1, "خاو باو زخم نکن قفل استیکر رو بازکردم الان", 1, "html")
end
end

----Force Join
if text:match("^لورا دعوت اجباری رو فعال کن$") and is_mod(msg) and is_JoinChannel(msg)then
redis:set("sg:joinchat"..msg.chat_id,"lock")
if redis:get("bot:ans"..msg.chat_id) == nil then
sendMessage(msg.chat_id, msg.id, 1, "اد اجباری گروه رو فعال کردم عزیز!", 1, "html")
else
sendMessage(msg.chat_id, msg.id, 1, "گاییدن ممبر رو فعال کردم حالا باس بیچاره اد بزنه تابتونه گو بخوره تو گپ", 1, "html")
end
elseif text:match("لورا دعوت اجباری رو غیرفعال کن") and is_mod(msg) and is_JoinChannel(msg)then
redis:del("sg:joinchat"..msg.chat_id)
if redis:get("bot:ans"..msg.chat_id) == nil then
sendMessage(msg.chat_id, msg.id, 1, "اد اجباری گروه رو غیرفعال کردم عزیز!", 1, "html")
else
sendMessage(msg.chat_id, msg.id, 1, "گاییدن ممبر رو غیرفعال کردم حالا میتونه 24 گو بخوره", 1, "html")
end
end
if text:match("^تعداد دعوت (.*)$") and is_mod(msg) and is_JoinChannel(msg) then
local input = text:match("^تعداد دعوت (.*)$")
if tonumber(input) < 2 or tonumber(input) > 10 then
if redis:get("bot:ans"..msg.chat_id) == nil then
sendMessage(msg.chat_id, msg.id, 1, "عزیزم لطفا بین عدد 2تا 10 انتخاب کن مرسی", 1, "html")
else
sendMessage(msg.chat_id, msg.id, 1, "کصخل برا گاییدن ممبر بین 2تا10 انتخاب کن", 1, "html")
end
else
redis:set("setjoin"..msg.chat_id,input)
if redis:get("bot:ans"..msg.chat_id) == nil then
sendMessage(msg.chat_id, msg.id, 1, "مقدار تعداد اد اجباری گروه شما به ["..input.."] تغییر کرد!", 1, "html")
else
sendMessage(msg.chat_id, msg.id, 1, "تعداد نفراتیی ک ممبرا برا گوه خوردن تو گپ باس اد کنن به ["..input.."] تغییر کرد!", 1, "html")
end
end
end

---- Cleans
if text:match("لورا پاکسازی دیلیت اکانتی ها") and is_JoinChannel(msg)and is_mod(msg) then
local function deleteaccounts(extra, result)
if result.members then
for k,v in pairs(result.members) do 
local function cleanaccounts(extra, result)
if result.type._ == "userTypeDeleted" then
kickuser(msg.chat_id, result.id)
end
end
getUser(v.user_id, cleanaccounts, nil)
end
end
if redis:get("bot:ans"..msg.chat_id) == nil then
sendMessage(msg.chat_id, msg.id, 1, "خب حله دیلیت اکانتی هارو پاک کردم رفت!", 1, "html")
else
sendMessage(msg.chat_id, msg.id, 1, "خب حله کصخلایی ک دیل زدن ازتلو پاکیدم!", 1, "html")
end
end 
tdbot_function ({_= "getChannelMembers",channel_id = getChatId(msg.chat_id).id,offset = 0,limit= 1000}, deleteaccounts, nil)
end


-----------------
if text:match("لورا پاکسازی بلک لیست") and is_JoinChannel(msg) and is_mod(msg) then
local function removeblocklist(extra, result)
if tonumber(result.total_count) == 0 then 
if redis:get("bot:ans"..msg.chat_id) == nil then
sendMessage(msg.chat_id, msg.id, 1, "بلاک لیست گروه شما خالی است", 1, "html")
else
sendMessage(msg.chat_id, msg.id, 1, "کصخلای بن شده نداری هاجی", 1, "html")
end
else
local x = 0
if result.members then
for x,y in pairs(result.members) do
x = x + 1
Left(msg.chat_id, y.user_id)
end
end
if redis:get("bot:ans"..msg.chat_id) == nil then
sendMessage(msg.chat_id, msg.id, 1, "خب حله بلک لیست گروهو خالی کردم!", 1, "html")
else
sendMessage(msg.chat_id, msg.id, 1, "خب کصخلایی ک سیکشون کردی رو پاک کردم!", 1, "html")
end
end
end
getChannelMembers(msg.chat_id, 0, 100000, "Banned", removeblocklist)
end

-----------------
if text:match("لورا رباتارو پاک کن") and is_mod(msg) and is_JoinChannel(msg) then
local function botslist(extra, result)
if result.members then
for k,v in pairs(result.members) do
kickuser(msg.chat_id, v.user_id)
end
end
end
if redis:get("bot:ans"..msg.chat_id) == nil then
sendMessage(msg.chat_id, msg.id, 1, "حله کل رباتارو پاک کردم!", 1, "html")
else
sendMessage(msg.chat_id, msg.id, 1, "حله کل رباتای سگی رو پاک کردم!", 1, "html")
end
getChannelMembers(msg.chat_id, 0,200, "Bots", botslist)
end
-----------------
if text:match("clean mem") and is_sudo(msg) then
do
local function checkclean(user_id)
local var = false
if is_admin(user_id) then
var = true
end
if tonumber(user_id) == tonumber(our_id) then
var = true
end
return var
end
local function cleanmember(extra, result)
if result.members then
for k,v in pairs(result.members) do
if not checkclean(v.user_id) then
kickuser(msg.chat_id, v.user_id)
end
end
end
end
local d = 0
for i = 1, 5 do
getChannelMembers(msg.chat_id, d,200, "Recent", cleanmember)
d = d + 200
end
sendMessage(msg.chat_id, msg.id, 1, "حله :))))", 1, "html")
end
end
--------------
if text:match("^لورا خوشامدگویی رو فعال کن$") and is_mod(msg) and is_JoinChannel(msg) then
redis:set("sg:welcome"..msg.chat_id,"lock")
if redis:get("bot:ans"..msg.chat_id) == nil then
sendMessage(msg.chat_id, msg.id, 1, "خوشامد گویی گروه فعال شد!", 1, "html")
else
sendMessage(msg.chat_id, msg.id, 1, "کص گویی به اعضای جدید فعال شد!", 1, "html")
end
elseif text:match("^لورا خوشامدگویی رو غیرفعال کن$") and is_mod(msg) and is_JoinChannel(msg) then
redis:del("sg:welcome"..msg.chat_id)
if redis:get("bot:ans"..msg.chat_id) == nil then
sendMessage(msg.chat_id, msg.id, 1, "خوشامد گویی گروه غیر فعال شد!", 1, "html")
else
sendMessage(msg.chat_id, msg.id, 1, "کص گویی به اعضای جدید غیرفعال شد!", 1, "html")
end
end
if text:match("^تنظیم خوشامدگویی (.*)$") and is_mod(msg)then
local input = {
string.match(text, "تنظیم خوشامدگویی (.*)$")
}
redis:set("bot:txtwel"..msg.chat_id,input[1])
sendMessage(msg.chat_id, msg.id, 1, input[1], 1, "md")
end
if msg.content._ == "messageChatJoinByLink" or msg.content._ == "messageChatAddMembers" then
if redis:get("sg:welcome"..msg.chat_id) == "lock" then
if redis:get("msgssa"..msg.chat_id) then
deleteMessages(msg.chat_id, {[0] = redis:get("msgssa"..msg.chat_id)})
end
function welcome_user(a,b)
if not redis:get("bot:txtwel"..msg.chat_id) then
--if redis:get("bot:ans"..msg.chat_id) == nil then
texts = "سلام گلم😇😇 خوش اومدی فداتم❤️\n"
--else
--texts = "سلام کصخله خوش اومدی\n"
--end
else
texts = redis:get("bot:txtwel"..msg.chat_id)
if texts then
if texts:match("{name}") then
texts = texts:gsub("{name}", b.first_name)
elseif texts:match("{username}") then
if b.username then
user_name = "@"..check_markdown(b.username)
else
user_name = b.first_name
end
texts = texts:gsub("{username}", user_name)
end
end
end
sendMessage(msg.chat_id, 0, 1, texts, 1, "html")
end
getUser(user_id , welcome_user)
end
end
------------------AI----------------
--Salam
if text:match("^لورا سلام$") or text:match("^لوراسلام$") or text:match("^سلام لورا$") or text:match("^salam lura$")or text:match("^slm lura$")or text:match("^slm$")or text:match("^lura slm$")or text:match("^lura salam$")and CMD then
if redis:get("bot:ans"..msg.chat_id) == nil then
local datebase ={
"سلام عزیزم",
"سلام گلم",
"سلام تنفس",
"سلام جانم",
"سلام سلام خوبی؟"
}
sendMessage(msg.chat_id, 0, 1,datebase[math.random(#datebase)], 1, "html")
else
local datebase ={
"سلام کصخل خان",
"سلام کیری",
"سلام جقی",
"سلام کونی جون",
"سلام جیندا"
}
sendMessage(msg.chat_id, 0, 1,datebase[math.random(#datebase)], 1, "html")
end
end
--Khobi
if text:match("^لورا خوبی$") or text:match("^لورا خوبی؟$") or text:match("^خوبی لورا$") or text:match("^خوبی لورا؟$") or text:match("^khobi lura$") or text:match("^khobi lura?$")or text:match("^lura khobi?$")or text:match("^khobi$")or text:match("^lura khobi$")and CMD then
if redis:get("bot:ans"..msg.chat_id) == nil then
local datebase ={
"مرسی من خوبم تو خوبی؟",
"فداتشم من عالیم",
"اوهوم تو چطوری",
"به خوبیت خوبم",
"بعلههه ک خوبم معلومه ک خوبم"
}
sendMessage(msg.chat_id, 0, 1,datebase[math.random(#datebase)], 1, "html")
else
local datebase ={
"ها خوبم تو کصخل چطوری",
"به تو چه کونی ک خوبم یا نه",
"کیرم خوبه میخوای ببینیش؟",
"اگر بسیکی خوبم",
"تا تو جنده هسی ن سگ سگم"
}
sendMessage(msg.chat_id, 0, 1,datebase[math.random(#datebase)], 1, "html")
end
end
if text:match("^لورا چه خبرا$") or text:match("^لورا چه خبر$") or text:match("^لورا چه خبرا؟$") or text:match("^لورا چه خبر؟$") or text:match("^چه خبرا لورا$") or text:match("^چه خبرا لورا$")or text:match("^lura che khabar$")or text:match("che khabar lura$")or text:match("^che khabara lura$") or text:match("^لورا چ خبرا؟؟$")and CMD then
if redis:get("bot:ans"..msg.chat_id) == nil then
local datebase ={
"هعی میگذره تو چه خبر",
"هیچی نشستم شمارو میبینم چت میکنید والا :)",
"بیکار همینطوری نشستم",
"خبر مبری نیست والا!",
"فضولی مگه؟؟"
}
sendMessage(msg.chat_id, 0, 1,datebase[math.random(#datebase)], 1, "html")
else
local datebase ={
"هیچی دارم عمتو میکنم مزاحم نشو",
"ها دارم جق میزنم",
"دارم پورن میبینم",
"دارم فیلم میبینم برو گو نخور مزاحم نشو",
"گو خور منی مگه؟"
}
sendMessage(msg.chat_id, 0, 1,datebase[math.random(#datebase)], 1, "html")
end
end
if text:match("^لورا حالت چطوره$") or text:match("^لورا حالت چطوره؟$") or text:match("^حالت چطوره لورا$") or text:match("^حالت چطوره لورا؟$") or text:match("^lura halet chetore?$") or text:match("^lura halet chetore$")or text:match("^chetore halet lura$")or text:match("chetore halet lura?$")and CMD then
if redis:get("bot:ans"..msg.chat_id) == nil then
local datebase ={
"عالی عالی 😊😊",
"یخورده خسته ام ولی خب خسته دشمنه 🤪پس خوب خوبم🥰",
"اومم 🤮🤧مریض شدم بدجور",
"😈هیچی شیطونیم گرفته",
"😐حالمو چیکار داری ب تو چه والا🤤"
}
sendMessage(msg.chat_id, 0, 1,datebase[math.random(#datebase)], 1, "html")
else
local datebase ={
"کیریه حالم کیری عمت بهم کص نداده",
"خستم مثل اون پسری که دوست دخترشو اورد تو خونشون ولی دید کیرداره دختره",
"شق کردم حالم تخمیه",
"کصخل کردم فیلم سوپر دیدم دق کردم"
}
sendMessage(msg.chat_id, 0, 1,datebase[math.random(#datebase)], 1, "html")
end
end
if text:match("^لورا بساک$") or text:match("^لورا کون بده$") or text:match("^لورا کص بده$") or text:match("^لورا کس بده$") or text:match("^لورا بکنمت$") or text:match("^لورا گاییدمت$")or text:match("^لورا کص ننت")or text:match("لورا کیرم دهنت$") or text:match("^لورا میخاری$") or text:match("^لورا کیری$")or text:match("^لورا جاکشی$")or text:match("^کیرم دهنت لورا$")or text:match("^کص بده لورا$")or text:match("^لورا ممه بده$")or text:match("^ممه بده لورا$")or text:match("^بکنمت لورا$")or text:match("^بساک لورا$")or text:match("^besak lura$")or text:match("^besac lura$")or text:match("^lura besak$")or text:match("^lura besac$")or text:match("^kir tot lura$")or text:match("^lura kir tot$")or text:match("^lura kos nnt$")or text:match("^lura kos nanat$")or text:match("^kos nanat lura$")or text:match("^kos nnt lura$")or text:match("^lura kiram dahanet$")or text:match("^kiram dahanet lura$")or text:match("^bokonamet lura$")or text:match("^lura bokonamet$")or text:match("^لورا خارتو$") or text:match("^خارتو لورا$") or text:match("^لورا کص بده$") or text:match("^لورا گاییده شدی$") or text:match("^لورا بپا نگامت$") or text:match("^لورا گاییدمت$")or text:match("^لورا مادرتو$")or text:match("^لورا حرومزاده$") or text:match("^لورا بده بکنیم$") or text:match("لورا ی جیندا بیار") or text:match("^لورا کیر میخوری$") or text:match("^لورا هدشو بگیر$") and CMD then
if redis:get("bot:ans"..msg.chat_id) == nil then
local datebase ={
"هاجی من رباتم خیلی بیشوری ک همچین چیزایی بمن میگی 😕الحق مادر پدرت بهت شعور یاد ندادن احمق بی ادب😒",
"عقده ای بدبختو ببین چیا میگه خیلی بدبختی😒😒بیچاره😒",
"خاک توسرت این حرفارو میزنی خاک خاک😕😕",
"شیطونه میگه جوابتو بدما😒ولی خب من با ادبم🙄🙄مثل شما بیشور نیسم😤",
"حرفی ندارم انقد بیشوری 😕بیشور😕بدبخت😕بیشور بدبخت😕"
}
sendMessage(msg.chat_id, 0, 1,datebase[math.random(#datebase)], 1, "html")
else
local datebase ={
"کص عمت باو مرتیکه حرومی من رباتم خجالت بکش",
"جاکش کصکش خر الاغ کونی کیرم دهنت",
"کص عمت جاکش بیا کیرمو بخور",
"کص نگو کیری مقام کصخل",
"جاکش بیا کیرمو بخور باو لاشی"
}
sendMessage(msg.chat_id, 0, 1,datebase[math.random(#datebase)], 1, "html")
end
end
if text:match("^لورا چیکارا میکنی$") or text:match("^لورچی کار میکنی$") or text:match("^لورا چه کارمیکنی$") or text:match("^لورا چه کار میکنی$") or text:match("^چه کارمیکنی لورا$") or text:match("^چیکار میکنی لورا$")or text:match("^چیکارا میکنی لورا$")or text:match("^چ میکنی لورا$")or text:match("^لورا چ میکنی$")and CMD then
if redis:get("bot:ans"..msg.chat_id) == nil then
local datebase ={
"حواسم به گروهت هست دیگه",
"هیچکار نمیکنم فضول نشستم همینجا",
"اوم دارم سرورمو تمیز میکنم خوب بشه سرعتم",
"هیچ دارم توی گروها جواب مردمو که صدام میزنن میدم",
"بیکارم گلم"
}
sendMessage(msg.chat_id, 0, 1,datebase[math.random(#datebase)], 1, "html")
else
local datebase ={
"جق میزنم",
"کص میکنم",
"کون میکنم",
"دارم تورو میگام",
"دارم به یاد عمت میزنم"
}
sendMessage(msg.chat_id, 0, 1,datebase[math.random(#datebase)], 1, "html")
end
end
if text:match("^لورا بوس بده$") or text:match("^لورا بوس$") or text:match("^لورا بوس میدی$") or text:match("^بوس بده لورا$") or text:match("^بوس لورا$") or text:match("^بوس میدی لورا$")and CMD then
if redis:get("bot:ans"..msg.chat_id) == nil then
local datebase ={
"🥰😘اینم بوس",
"عه عه زشته🙊🙈😘",
"بوس میخواااااااااای عهههههههههه عه من رباتم ک🙄 ولی خب باج بیا جلو😘",
"نمیدم😒خجالتم خوب چیزیه برو از رلت بگیر",
"برو بترک بوس میخاد خجالتم نمیکشه"
}
sendMessage(msg.chat_id, 0, 1,datebase[math.random(#datebase)], 1, "html")
else
local datebase ={
"به عمت جندت بگو بوس بده کصم بده",
"به رل جندت بگو بهت بوس بده باو",
"کیر دارم بدم بت؟ بخوری جاکش",
"کیری برو داش کونیتو بوس کن"
}
sendMessage(msg.chat_id, 0, 1,datebase[math.random(#datebase)], 1, "html")
end
end
if text:match("^لورا بخند$") or text:match("^بخند لورا$") and CMD then
if redis:get("bot:ans"..msg.chat_id) == nil then
local datebase ={
"😂😂بیا اینم خندیدم به عشق تو",
"😐خندم نمیاد",
"🤣🤣🤣"
}
sendMessage(msg.chat_id, 0, 1,datebase[math.random(#datebase)], 1, "html")
else
local datebase ={
"به عمه کصکشت دارم میخندم",
"😐خندم نمیاد چون تو بهم کون ندادی",
"🤣🤣🤣کص عمت"
}
sendMessage(msg.chat_id, 0, 1,datebase[math.random(#datebase)], 1, "html")
end
end
if text:match("^لورا گریه کن$") or text:match("^گریه کن لورا$") and CMD then
if redis:get("bot:ans"..msg.chat_id) == nil then
local datebase ={
"😭😭 دلت اومد گفتی گریه کنم؟",
"😐گریه نمیکنم",
"😭😭😭 هعی بیا اینم گریه"
}
sendMessage(msg.chat_id, 0, 1,datebase[math.random(#datebase)], 1, "html")
else
local datebase ={
"من برا عمت گریه میکنم که جندس",
"گریه میکنم ک تو کصکش بهم کون نمیدی",
"به اون عمه جندت بگو گریه کن باو"
}
sendMessage(msg.chat_id, 0, 1,datebase[math.random(#datebase)], 1, "html")
end
end
if text:match("^لورا بده$") and CMD then
if redis:get("bot:ans"..msg.chat_id) == nil then
local datebase ={
"چی میخوری بدم : )؟",
"چی بدم ازونا ک باعث خفه گی میشه",
"چیزی ندارم بدم"
}
sendMessage(msg.chat_id, 0, 1,datebase[math.random(#datebase)], 1, "html")
else
local datebase ={
"کیر بدم بهت کصخل؟",
"گوه میخای گو بدم بهت",
"جز تخمام چیزی نرم میخای بدم؟"
}
sendMessage(msg.chat_id, 0, 1,datebase[math.random(#datebase)], 1, "html")
end
end
if text:match("^لورا بگوز$") or text:match("^بگوز لورا$")and CMD then
local datebase ={
"/home/lura/td/goz/goz1.ogg",
"/home/lura/td/goz/goz2.ogg",
"/home/lura/td/goz/goz3.ogg",
"/home/lura/td/goz/goz4.ogg",
"/home/lura/td/goz/goz5.ogg",
"/home/lura/td/goz/goz6.ogg",
"/home/lura/td/goz/goz7.ogg",
"/home/lura/td/goz/goz8.ogg",
"/home/lura/td/goz/goz9.ogg",
"/home/lura/td/goz/goz10.ogg"
}
local file = datebase[math.random(#datebase)]
sendVoice(msg.chat_id,msg.id,file,0,waveform,"@botcollege")
end
if text:match("^لورا بمیر$") or text:match("^بمیر لورا$")and CMD then
if redis:get("bot:ans"..msg.chat_id) == nil then
local datebase ={
"دلت میاد من بمیرم :( ؟",
"من رباتم نمیمیرم بسووووووووووز",
"خودت برو بمیر بی ادب"
}
sendMessage(msg.chat_id, 0, 1,datebase[math.random(#datebase)], 1, "html")
else
local datebase ={
"جاکش عمه جندت بمیره",
"بیا کیرمو بخور بمیر کصکش",
"خودت برو بمیر کصکش سگ"
}
sendMessage(msg.chat_id, 0, 1,datebase[math.random(#datebase)], 1, "html")
end
end
end
end
end
---------------------------------------------------------------------
function tdbot_update_callback(data)
if (data._ == "updateNewMessage") or (data._ == "updateNewChannelMessage") then
run(data.message,data)
elseif (data._ == "updateMessageSendSucceeded") then
local msg = data.message	
local text = msg.content.text
openChat(chat_id)
if text then 
if not redis:get("bot:txtwel"..msg.chat_id) then
texts = "خوش اومدیツ"
else
texts = redis:get("bot:txtwel"..msg.chat_id)
end
if text == texts then
print(msg.id)
redis:set("msgssa"..msg.chat_id,msg.id)
end
end
elseif (data._== "updateMessageEdited") then
run(data.message,data)
msg = data
local function edit(a,b,c)
run(b,data)
end
assert (tdbot_function ({_ = "getMessage", chat_id = data.chat_id,message_id = data.message_id }, edit, nil))
assert (tdbot_function ({ _ = 'openMessageContent',chat_id = data.chat_id,message_id = data.message_id}, dl_cb, nil))
assert (tdbot_function ({_="getChats",offset_order="9223372036854775807",offset_chat_id=0,limit=20}, dl_cb, nil))
end
end

-- End Of LuRa Bot

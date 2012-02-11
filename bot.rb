require 'cinch'

class Identify
	include Cinch::Plugin

	listen_to :connect, method: :identify

	def identify(m)
		User("nickserv").send("identify PASSWORD")
	end
end

bot = Cinch::Bot.new do
	configure do |c|
		c.nick = "HackerSchoolBot"
		c.realname = "Hacker School IRC Bot"
		c.server = "irc.freenode.org"
		c.channels = ["#HackerSchool"]
		c.plugins.plugins = [Identify]
	end

	helpers do
		def is_admin?(user)
			if user.nick == "omni5cience"
				true
			else
				false
			end
		end
	end

	on :message, /(HS|HackerSchoolBot)+[_: ]*(hello|hi)/i do |m|
		m.reply "Hello, #{m.user.nick}"
	end

	on :message, /(HS|HackerSchoolBot)*[_: ]*help/i do |m|
		m.reply "Prefix commands with either HS: or HackerSchoolBot: \nCurrently I know: hello, roll, botherEVERYBODY(squash, ping, timetogo)"
	end

	on :message, /^!join (.+)/ do |m, channel|
		m.reply("You're not my mommy!") unless is_admin?(m.user)
		bot.join(channel) if is_admin?(m.user)
	end

	on :message, /^!part (.+)/ do |m, channel|
		m.reply("You're not my mommy!") unless is_admin?(m.user)
		channel = channel || m.channel

		if channel
			bot.part(channel) if is_admin?(m.user)
		end
	end

	on :message, /^HS|HackerSchoolBot[_: ]*roll(?: (.+))?$/i do |m, sides|
		begin
			m.reply sides ? (1 + rand(Integer(sides))) : 4
		rescue
			m.reply "That is not a number."
		end
	end

	on :message, /.*butternut.*/i do |m|
		m.reply "That command is obsolete use HS:botherEVERYBODY"
	end

	on :channel, /^(HS|HackerSchoolBot)[_: ]*(botherEVERYBODY|squash|timeToGo|ping)/i do |m, pre, command|
		alertString = "Hey you!"
		everybody = m.channel.users.keys.uniq

		everybody.map! do |user|
			unless (user.nick == m.user.nick || user.nick == bot.nick)
				user.nick
			end
		end

		everybody.uniq!
		alertString << everybody.join(" ")

		case command.downcase
		when "timetogo"
			alertString << "\nIT'S TIME TO GO!"
		when "bothereverybody"
			alertString << "\nPay attention!"
		when "squash"
			alertString << "\nI LIKE SQUASH!\nAlso, butternut"
		when "ping"
			alertString << "\nPING!"
		end
		m.reply alertString
	end
end

File.open("tmp/HSBot.pid", 'w+') do |io|
	io.puts Process.pid
end

trap "INT" do
	bot.quit "Got SIGINT, bye bye."
end

bot.start

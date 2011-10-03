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
		c.channels = ["#HackerSchoolTest"]
		c.plugins.plugins = [Identify]
	end

	@admin = "omni5cience"

	helpers do
		def is_admin?(user)
			true if user.nick == @admin
		end
	end

	on :message, /(HS|HackerSchoolBot)+[: ]+(hello|hi)/i do |m|
		m.reply "Hello, #{m.user.nick}"
	end

	on :message, /(HS|HackerSchoolBot)+[: ]+help/i do |m|
		m.reply "Prefix commands with either HS: or HackerSchoolBot: \nCurrently I know: hello, botherEVERYBODY(squash)"
	end

	on :message, /^!join (.+)/ do |m, channel|
		bot.logger.debug is_admin?(m.user).to_s
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

	on :channel, /^(HS|HackerSchoolBot)[: ]+(botherEVERYBODY|squash)/ do |m|
		alertString = "Hey you!"
		everybody = m.channel.users
		everybody.each do |user, flags|
			bot.logger.debug user
			bot.logger.debug bot.nick
			if(user.nick == m.user.nick || user.nick == bot.nick)
				bot.logger.debug "Nick #{user.nick}"
			else
				alertString << " #{user.nick}:"
			end
		end
		m.reply alertString
		bot.logger.debug "#{m.user.nick} used the really annoying command"
	end
end

File.open("tmp/HSBot.pid", 'w+') do |io|
	io.puts Process.pid
end

trap "INT" do
	bot.quit "Got SIGINT, bye bye."
end

bot.start

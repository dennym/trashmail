require 'sinatra'
# require 'redis'

configure do
	SiteConfig = OpenStruct.new(
		:title => 'trashmail » fast secure anonym',
		:author => 'Denny Mueller',
		:url_base => 'http://localhost:4567/', # the url of your application
		:username => 'admin',
		:token => 'maketh1$longandh@rdtoremember',
		:password => 'password'
	)
end

# r = Redis.new

helpers do
	include Rack::Utils
	alias_method :h, :escape_html

	def random_string(length)
		rand(36**length).to_s(36)
	end

	def get_site_url(short_url)
		SiteConfig.url_base + short_url
	end

	def admin?
		request.cookies[SiteConfig.username] == SiteConfig.token
	end

	def protected!
		redirect '/login' unless admin?
	end

	def check_receiver_email(mail)
		unless mail.match(/^[^@]+@ichtudas\.de$/)
			return false
		else
			return true
		end
end


get '/' do
	erb :index
end

post '/' do
	seconds = 60
	unless params[:url] =~ /\+(\d+)min/
		expire = 3600 # seconds has 1 hour 
	else
		expire = params[:url].match(/\+(\d+)min/)[1]
	end
	## to remove the +Xmin
	.gsub(/\+(\d+)min/,"")
	##
end

post '/mailin' do
	mail = {"headers"=>"Received: by mx-001.sjc1.sendgrid.net with SMTP id E2cPFT6Myh Sun, 19 Jan 2014 23:20:30 +0000 (GMT)\nReceived: from taurus.uberspace.de (taurus.uberspace.de [95.143.172.102]) by mx-001.sjc1.sendgrid.net (Postfix) with ESMTPS id AF1D44C258E for <hello@ichtudas.de>; Sun, 19 Jan 2014 23:20:29 +0000 (GMT)\nReceived: (qmail 29891 invoked from network); 19 Jan 2014 23:20:25 -0000\nReceived: from unknown (HELO ?192.168.178.56?) (denny@dennymueller.de@77.188.116.0) by taurus.uberspace.de with ESMTPA; 19 Jan 2014 23:20:25 -0000\nMessage-ID: <1390173623.10204.14.camel@denym-ThinkPad-T530>\nSubject: test subject\nFrom: Denny Mueller <denny@dennymueller.de>\nTo: hello@ichtudas.de\nDate: Mon, 20 Jan 2014 00:20:23 +0100\nContent-Type: text/plain\nX-Mailer: Evolution 3.8.2-0ubuntu1~raring1 \nMime-Version: 1.0\nContent-Transfer-Encoding: 7bit\n", "dkim"=>"none", "to"=>"hello@ichtudas.de", "from"=>"Denny Mueller <denny@dennymueller.de>", "text"=>"\r\nlawdjawfaw\r\n\r\n\n", "sender_ip"=>"95.143.172.102", "envelope"=>"{\"to\":[\"hello@ichtudas.de\"],\"from\":\"denny@dennymueller.de\"}", "attachments"=>"0", "subject"=>"test subject", "charsets"=>"{\"to\":\"UTF-8\",\"subject\":\"UTF-8\",\"from\":\"UTF-8\",\"text\":\"iso-8859-1\"}", "SPF"=>"none"}
	if check_receiver_email(mail['to']) = true and not mail.empty?

		params[:url] = "http://#{params[:url]}"
		@shortcode = random_string 5
		r.multi do
			r.set "links:#{@shortcode}", params[:url], :nx => true, :ex => expire
		end
	end
	return 200
end

get '/login' do
	erb :login
end

post '/login' do
	if params[:username]==SiteConfig.username&&params[:password]==SiteConfig.password
			response.set_cookie(SiteConfig.username,SiteConfig.token) 
			redirect '/admin'
		else
			redirect '/admin'
		end
end

get '/logout' do
	response.set_cookie(SiteConfig.username, false)
	redirect '/'
end

get '/admin' do
	protected!
	erb :admin
end

not_found do
	'This is nowhere to be found.'
end

get '/:shortcode' do
	protected!
end
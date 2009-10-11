require 'cgi'
require 'rubygems'
require 'patron'
require 'hpricot'
class NanzhouCrawler
	def initialize
		@session_config = {"Content-Type"=>'application/x-www-form-urlencoded',
			"User-Agent" => "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.1.2) Gecko/20090729 Firefox/3.5.2",
			"Referer" => "http://www.infzm.com/enews/infzm",
			"Cookie" => %[d041ab46875f9b703c33b8d4c126c757=+4+F+15F1E585E+7+D46+B+E5B1B56+44C405D+759445E5F5B535F4659+05C16145C52+A+95846+C4B; PHPSESSID=j9kh4tgje6lrbeg47bavdl82q6; __utmc=118487249; __utmz=118487249.1255250270.2.2.utmccn=(organic)|utmcsr=google|utmctr=%E5%8D%97%E6%96%B9%E5%91%A8%E6%9C%AB|utmcmd=organic; __utma=118487249.1960636661.1255245331.1255245331.1255250270.2; OAID=25e4cf710198ddf0d10943a88a72b4b4; __utmb=118487249]

		}
		@base_url = 'http://www.infzm.com/'
	end
	
	def parse
		doc = Hpricot(session.get("content/35661").body)
	end
	
	private
	def session
		unless @session
			sess = Patron::Session.new
			sess.handle_cookies
			sess.base_url = @base_url
			@session_config.each do |k,v|
				sess.headers[k] = v
			end
			@session = sess
		end
		@session
	end

end
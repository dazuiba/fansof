#!/usr/bin/ruby
require 'singleton'
require 'cgi'
require 'rubygems'
require 'patron'
require 'hpricot'
require 'extensions/all'

module ParseModule
	attr_reader :doc
	def do_request(path)
		@doc = new_request(path)
	end
	
	def new_request(path)
		puts "Request #{path}"
		Nanzhou.instance.get_doc(path)
	end
	
	def at(path)
		doc.at(path)
	end
	
	def at_html(path)
		at(path).inner_html
	end
	
	def at_text(path)
		at(path).inner_text
	end
	
	def search(path)
		doc.search(path)
	end	
	
	def at_url_pair(path)
		a = at(path)
		[a['href'], a.inner_html]
	end
end

class Journal
	URL_BASE = 'enews/infzm/'	
	PART = {'经济'=>0, '评论'=>1, '新闻'=>2, '时局'=>3, '绿色' =>4 , '文化'=>5}
	include ParseModule
	attr_accessor :id, :name, :headline, :parted_content
	
	def initialize(url, name)
		url.chomp("/") =~/(\d+)$/
		@id = $1.to_i
		raise "id #{$1} is not valid" if @id <= 0
		@name = name
	end
	
	def parse!
		do_request(URL_BASE+self.id.to_s)
		self.headline = create_content(at(".topnews a"), :head, 0,at_text(".topnews .summary"))
		raise if headline.nil?
		self.parted_content = search(".side-2 h2").map{|e|parse_parts(e, PART[e.inner_text])}
	end		
	
	def parse_parts(element, part)
		next_node = element.next
		while next_node&&(next_node = next_node.next).text?
			puts "ingore text"
		end
		next_node.search(".relnews li a").map_with_index do |a, i|
			create_content(a, part , i)
		end
		
	end
	
	
	private
	def create_content(href_element, part, position_of_part, subtitle=nil)
		url, title = href_element['href'], href_element.inner_text
		url =~/(\d+)$/
		
		Content.from_hash(:journal=>self, :id => $1, 
							  :part=>part, :position_of_part=>position_of_part, 
							  :title => title,  :title2=> subtitle )
	end
end

class Content < Struct.new(:journal, :id, :part, :title, :position_of_part, :title2) 
	URL_BASE = 'content/'
	include ParseModule
	attr_reader :pages, :author, :publish_at
	def self.from_hash(hash)
		result = self.new
		hash.each{|k,v|result[k]=v}
		result
	end
	def parse!
		do_request(URL_BASE+self.id.to_s)
		@author = at_text(".relInfo span.author strong")
		@publish_at = DateTime.parse(at_text(".relInfo span.pubTime"))
		@pages = [at_html("#content-context")]
		pages = search("#pageNum .pages a")
		if(pages&&pages.pop)
			pages.each{|e| 
			e['href'] =~ /\/(\d+)$/
			@pages<< crawl_page($1)
			}
		end
	end
	
	def crawl_page(page_num)
		doc = new_request(URL_BASE+self.id.to_s+"/#{page_num}")
		doc.at("#content-context").inner_html
	end
end

class Nanzhou
  include Singleton
	def initialize
		@session_config = {"Content-Type"=>'application/x-www-form-urlencoded',
			"Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
			"User-Agent" => "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.1.2) Gecko/20090729 Firefox/3.5.2",
			"Referer" => "http://www.infzm.com/enews/infzm",
			# "Accept-Encoding" => "gzip,deflate",
			"Accept-Charset" => "ISO-8859-1,utf-8;q=0.7,*;q=0.7",
			"Accept-Language" => "en-us,en;q=0.5",
			"Cookie" => %[PHPSESSID=t7ot0hth64p8q0i0sdaallps07; __utma=118487249.973348149.1255276544.1255276544.1255276544.1; __utmb=118487249; __utmc=118487249; __utmz=118487249.1255276544.1.1.utmccn=(organic)|utmcsr=google|utmctr=%E5%8D%97%E6%96%B9%E5%91%A8%E6%9C%AB|utmcmd=organic; OAID=0704d0594d5c9420942f7bb16db28e1f; d041ab46875f9b703c33b8d4c126c757=55+350+3425F+D565E15+A+0+21055504D415E+6+7165A+D+B+2+A46+3+258154550+356555F155D18]
		
		}
		@base_url = 'http://www.infzm.com/'
	end
	
	def get_doc(path)
		doc = Hpricot(session.get(path).body)
	end
	
	def parse_journals
		content = File.read(File.dirname(__FILE__)+"/index.html.data")
		result = Hpricot(content).search("select option").map do |option|
			Journal.new(option['value'], option.inner_html)
		end
		result
	end
	
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
if $0 == __FILE__
	js = Nanzhou.instance.parse_journals
	j = js.first
	j.parse!
	j.headline.parse!
end
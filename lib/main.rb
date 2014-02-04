# coding: utf-8
# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

puts "Start Program"

require 'user_stream'
require 'twitter'
require 'dotenv'
require 'yaml'
require File.dirname(__FILE__) + '/../conf.rb'
#require 'oauth'
#require "hashie"
Dotenv.load
#ENV.each do |n,v|
#  p "#{n}=>#{v}"
#  
#end

puts ENV["consumer_key"]
puts ENV["consumer_secret"]
puts ENV["access_token"]
puts ENV["access_token_secret"]
puts @ngword


twitter = Twitter::REST::Client.new(
  :consumer_key => ENV["consumer_key"],
  :consumer_secret => ENV["consumer_secret"],
  :access_token =>  ENV["access_token"],
  :access_token_secret => ENV["access_token_secret"]
)



stream = UserStream.client(
  :consumer_key => ENV["consumer_key"],
  :consumer_secret => ENV["consumer_secret"],
  :oauth_token =>  ENV["access_token"],
  :oauth_token_secret => ENV["access_token_secret"]
)

p stream

p twitter


me = twitter.user
puts me.to_yaml

flag = 0

my_sn = me.screen_name

begin
twitter.update("#{my_sn}が起動したよっ(at #{Time.now})")
 
rescue => se
p se
end
  
stream.user(:replies=>false) do |s|
  begin
    if s.has_key?("friends")
      p "pass beacuse this is Friends object"
    elsif s.has_key?("delete")
      p "delete event happen"
#      twitter.update("ツイ消しを見た！(#{s[:delete].status.id_str})")
      p s
    elsif s.has_key?("event")
      p "#{s.event} => @#{s.source.screen_name} #{s.source.text}"
    elsif s.has_key?("warning")
      puts "Warn code => #{s.warning.code} :::: #{s.warning.message} "
      
    else
      
     puts "#{s.user.screen_name}\t#{s.text}"
#     puts s.user.following
     
      case s.text
      when /RT/
        p "pass becasuse RT"
        
      when /restart/
        if s.user.screen_name == my_sn
          flag = 0
          twitter.update("@#{s.user.screen_name} 再開するよ。" ,:in_reply_to_status_id  => s.id_str) 
        end
        
      when /stop/
        if s.user.screen_name == my_sn
          flag = 1
          twitter.update("@#{s.user.screen_name} わかった、停止するね。" ,:in_reply_to_status_id  => s.id_str) 
        end
        
      when /\(\s*\@#{my_sn}\s*\)/
        newn = s.text.sub(/\(\s*\@#{my_sn}\s*\)/,"")
      if flag == 1
        p "停止中なのでスルーします。(#{newn})"
      elsif /#{@ngword}/ =~ newn 
        
          twitter.update("@#{s.user.screen_name} 使用できない文言が含まれてるみたい！",:in_reply_to_status_id  => s.id_str)
          puts "#{newn} has NGword"

#        elsif s.user.screen_name != my_sn && !s.user.following 
#          puts "FF外からのリプライなので無視しました。"
#          p s
          
          
      else
        
        begin
          prof = twitter.update_profile(:name=>newn)
        rescue => ee
          p ee
          twitter.update("@#{s.user.screen_name} エラーが出たよっ！",:in_reply_to_status_id  => s.id_str)
        else
          twitter.update(".@#{s.user.screen_name}により名前が#{prof.name.gsub(/\@/,' (at) ')}に変えられたみたい。",:in_reply_to_status_id => s.id_str)
        end
#        twitter.update("マッチしたんだよとりあえず @#{s.user.screen_name}のﾂｨｯﾄが")
      end
      end
      
    end
    #puts s.to_yaml
  rescue => e
    p e
    p s
  end

end
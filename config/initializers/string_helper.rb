#BSA поддержка UTF-8 в строковых операциях с регистром символов не ASCII
#coding utf-8 http://s7at1c.ru/working-with-utf8-in-ruby.html
require "unicode"
class String

	#--------------------------------------- Обрезает лишнее, оставляя только первые n слов предложения и не изменяя пунктуацию.
	def first_n_words n
		text = self.clone
		words = text.scan(/[a-zA-Zа-яёА-ЯЁ]+/)[0..n-1]
		if words.size < n
			res = text
		else
			res = words.each_with_object([]){|k,v|t= text.index k; v << text[0..t+k.size-1]; text = text[t+k.size..-1]}.join
			res += "..." if res.size < self.size
		end
		res
	end

 def downcase
  Unicode::downcase(self)
 end

 def downcase!
  self.replace downcase
 end

 def upcase
  Unicode::upcase(self)
 end

 def upcase!
  self.replace upcase
 end

 def capitalize
  Unicode::capitalize(self)
 end

 def capitalize!
  self.replace capitalize
 end

  #---------------------------------------------------------------
  def black;          "\033[30m#{self}\033[0m" end
  def red;            "\033[31m#{self}\033[0m" end
  def green;          "\033[32m#{self}\033[0m" end
  def brown;          "\033[33m#{self}\033[0m" end
  def blue;           "\033[34m#{self}\033[0m" end
  def lightblue;      "\033[94m#{self}\033[0m" end
  def magenta;        "\033[35m#{self}\033[0m" end
  def lightmagenta;   "\033[95m#{self}\033[0m" end
  def cyan;           "\033[36m#{self}\033[0m" end
  def lightcyan;      "\033[96m#{self}\033[0m" end
  def gray;           "\033[37m#{self}\033[0m" end
  def yellow;         "\033[33m#{self}\033[0m" end
  def lightyellow;    "\033[93m#{self}\033[0m" end
  def bg_black;       "\033[40m#{self}\0330m"  end
  def bg_red;         "\033[41m#{self}\033[0m" end
  def bg_green;       "\033[42m#{self}\033[0m" end
  def bg_brown;       "\033[43m#{self}\033[0m" end
  def bg_blue;        "\033[44m#{self}\033[0m" end
  def bg_magenta;     "\033[45m#{self}\033[0m" end
  def bg_cyan;        "\033[46m#{self}\033[0m" end
  def bg_gray;        "\033[47m#{self}\033[0m" end
  def bold;           "\033[1m#{self}\033[22m" end
  def reverse_color;  "\033[7m#{self}\033[27m" end

end


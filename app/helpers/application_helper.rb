module ApplicationHelper
  def image?(str)
    str =~ /http:\/\/.*\.((png)|(jpg)|(bmp)|(gif))/
  end
end

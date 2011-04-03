module RageHelper
  def display_comic(comic) 
    str = ""
    str += "<h2>#{comic.title}</h2>"
    str += "<br />"
    str += "<img src=\"#{comic.link}\">"
    str += "<br />"
    str += "<br />"
  end
end

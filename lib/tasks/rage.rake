task :remove_viewed => :environment do
   Comic.delete_all("view = true AND created_at > :month", {:month => 1.month.ago})
end

task :empty_scraped => :environment do
  Comic.delete_all(:tweet => false, :queue => false, :queue => false)
end

task :remove_dupes => :environment do  
  comics = Comic.where(:tweet => true)
  comics.merge(Comic.where(:queue => true))

  images = []
  comics.each do |c|
    images << c.link
  end
  
  Comic.all do |c|
    if images.include?(c.link)
      c.destroy
    else
      images << c.link
    end
  end
end

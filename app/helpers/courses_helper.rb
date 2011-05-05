module CoursesHelper

  def setup_course(course)
    returning(course) do |c|
      c.batches.build if c.batches.empty?
    end
  end

end

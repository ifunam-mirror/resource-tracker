require 'zlib'
require 'json'

class DataMigrationJob < ActiveJob::Base
  queue_as :default

  def perform(backup_path)
    return unless File.exist? backup_path
    destroy_all
    @json = Zlib::GzipReader.open(backup_path).read
    JSON.parse(@json)['projects'].each do |p|
      import_project(p)
    end
  end

  private

  def destroy_all
    [Expenditure, Line, Project].collect(&:destroy_all)
  end

  def import_user(u)
    if User.where(login: u['login']).exists?
      User.where(login: u['login']).first
    else
      User.create(u.merge!(password: u['key'], password_confirmation: u['key']))
    end
  end

  def import_lines(lines)
    lines.collect do |l|
      expenditures = l['expenditures']
      l.delete 'expenditures'
      @line = Line.new(l)
      expenditures.each do |e|
        @line.expenditures << Expenditure.new(e)
      end
      @line
    end
  end

  def import_project(p)
    @user = import_user(p['user'])
    p.delete_if { |k, v| v if k == 'user' }

    @lines = import_lines(p['lines'])
    p.delete_if { |k, v| v if k == 'lines' }

    @project = Project.new(p)
    @project.user = @user
    @project.save # Save it before to avoid troubles with its childrens
    @project.lines = @lines
    @project.save
  end
end

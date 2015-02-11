require 'spec_helper'

class Permissions < ActivePermission::Base
  def initialize
    can 'manage/root', :index
    can 'manage/root', :show
    can 'manage/root1', [:index, :show]
    can %w(manage/root2 manage/root3), :index
    can %w(manage/root4 manage/root5), [:index, :show]
    can :users, :rate do |user, rate|
      (user * 2) == (rate)
    end
  end
end

describe ActivePermission::Base do
  let(:permissions) { Permissions.new }
  it 'abilities on manage/root' do
    expect(permissions.can?('manage/root', 'index')).to eql(true)
    expect(permissions.can?('manage/root', 'edit')).to eql(false)
    expect(permissions.can?('manage/root', 'show')).to eql(true)
  end
  it 'abilities on manage/root1' do
    expect(permissions.can?('manage/root1', 'index')).to eql(true)
    expect(permissions.can?('manage/root1', 'edit')).to eql(false)
    expect(permissions.can?('manage/root1', 'show')).to eql(true)
  end
  it 'abilities on manage/{root2, root3}' do
    expect(permissions.can?('manage/root2', 'index')).to eql(true)
    expect(permissions.can?('manage/root2', 'edit')).to eql(false)
    expect(permissions.can?('manage/root2', 'show')).to eql(false)
    expect(permissions.can?('manage/root3', 'index')).to eql(true)
    expect(permissions.can?('manage/root3', 'edit')).to eql(false)
    expect(permissions.can?('manage/root3', 'show')).to eql(false)
  end
  it 'abilities on manage/{root2, root3}' do
    expect(permissions.can?('manage/root4', 'index')).to eql(true)
    expect(permissions.can?('manage/root4', 'edit')).to eql(false)
    expect(permissions.can?('manage/root4', 'show')).to eql(true)
    expect(permissions.can?('manage/root5', 'index')).to eql(true)
    expect(permissions.can?('manage/root5', 'edit')).to eql(false)
    expect(permissions.can?('manage/root5', 'show')).to eql(true)
  end
  it 'default to deny' do
    expect(permissions.can?('manage/unknown', 'show')).to eql(false)
  end
  it 'AccessDenied [ :controller, :action, :object ]' do
    expect{permissions.can!('users', 'rate', 2,5)}.to raise_error(ActivePermission::AccessDenied)
    begin
      permissions.can!('users', 'rate', 2,5)
    rescue => error
      expect(error.class).to eql(ActivePermission::AccessDenied)
      expect(error.controller).to eql('users')
      expect(error.action).to eql('rate')
      expect(error.resources).to eql([2,5])
      expect(error.to_s).to eql('Access denied in users::rate on resources [2, 5]')
    end
  end
end

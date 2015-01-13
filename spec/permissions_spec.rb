require 'spec_helper'

class Permissions < ActivePermission::Base
  def initialize
    can 'manage/root', :index
    can 'manage/root', :show
    can 'manage/root1', [:index, :show]
    can %w(manage/root2 manage/root3), :index
    can %w(manage/root4 manage/root5), [:index, :show]
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
end

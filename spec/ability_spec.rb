require 'spec_helper'

class Ability < ActivePermission::Ability
  def initialize
    can 'manage/root', :index
    can 'manage/root', :show
    can 'manage/root1', [:index, :show]
    can %w(manage/root2 manage/root3), :index
    can %w(manage/root4 manage/root5), [:index, :show]
  end
end

describe ActivePermission::Ability do
  let(:ability) { Ability.new }
  it 'abilities on manage/root' do
    expect(ability.can?('manage/root', 'index')).to eql(true)
    expect(ability.can?('manage/root', 'edit')).to eql(false)
    expect(ability.can?('manage/root', 'show')).to eql(true)
  end
  it 'abilities on manage/root1' do
    expect(ability.can?('manage/root1', 'index')).to eql(true)
    expect(ability.can?('manage/root1', 'edit')).to eql(false)
    expect(ability.can?('manage/root1', 'show')).to eql(true)
  end
  it 'abilities on manage/{root2, root3}' do
    expect(ability.can?('manage/root2', 'index')).to eql(true)
    expect(ability.can?('manage/root2', 'edit')).to eql(false)
    expect(ability.can?('manage/root2', 'show')).to eql(false)
    expect(ability.can?('manage/root3', 'index')).to eql(true)
    expect(ability.can?('manage/root3', 'edit')).to eql(false)
    expect(ability.can?('manage/root3', 'show')).to eql(false)
  end
  it 'abilities on manage/{root2, root3}' do
    expect(ability.can?('manage/root4', 'index')).to eql(true)
    expect(ability.can?('manage/root4', 'edit')).to eql(false)
    expect(ability.can?('manage/root4', 'show')).to eql(true)
    expect(ability.can?('manage/root5', 'index')).to eql(true)
    expect(ability.can?('manage/root5', 'edit')).to eql(false)
    expect(ability.can?('manage/root5', 'show')).to eql(true)
  end
  it 'default to deny' do
    expect(ability.can?('manage/unknown', 'show')).to eql(false)
  end
end

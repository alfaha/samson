require_relative '../test_helper'

describe DeployGroupSerializer do
  let(:deploy_group) { deploy_groups(:pod1) }
  let(:kubernetes_cluster) { kubernetes_clusters(:test_cluster) }

  describe 'a deploy group not associated with a kubernetes cluster' do
    it 'contains only the basic information when serialized' do
      parsed = JSON.parse(DeployGroupSerializer.new(deploy_group).to_json).with_indifferent_access
      parsed[:deploy_group][:id].must_equal deploy_group.id
      parsed[:deploy_group][:name].must_equal deploy_group.name
      parsed[:deploy_group][:kubernetes_cluster].must_be_nil
    end
  end

  describe 'a deploy group associated with a kubernetes cluster' do
    before do
      Kubernetes::Cluster.any_instance.expects(:namespace_exists?).returns(true)
      Kubernetes::ClusterDeployGroup.create!(cluster: kubernetes_cluster, deploy_group: deploy_group, namespace: 'pod1')
    end

    it 'contains the kubernetes cluster when serialized' do
      parsed = JSON.parse(DeployGroupSerializer.new(deploy_group).to_json).with_indifferent_access
      parsed[:deploy_group][:kubernetes_cluster].wont_be_nil
      parsed[:deploy_group][:kubernetes_cluster][:name].must_equal 'test'
      parsed[:deploy_group][:kubernetes_cluster][:config_filepath].must_equal '/tmp/config'
      parsed[:deploy_group][:kubernetes_cluster][:config_context].must_equal 'test'
    end
  end
end

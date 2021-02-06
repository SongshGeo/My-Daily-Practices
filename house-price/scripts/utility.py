import yaml,os

path1 = os.path.dirname(__file__)  # 获取当前文件的上级目录路径，即 utiliy
path2=os.path.dirname(path1)  # 获取文件夹的上一级目录路径，即 house-price

class YamlLoad():
    def __init__(self):
        with open(path1+"/config.yml",'r',encoding='utf-8') as fp:
            cc=fp.read()
        # self.xx=yaml.load(self.cc)#单独使用这种会报警告   
        # 可使用yaml.warnings({'YAMLLoadWarning': False})全局禁用警告
        self.r = yaml.unsafe_load(cc)#不安全的加载YAML语言的子集
    def load(self, file):
        return self.r[file]


if __name__ == '__main__':
    y = YamlLoad()
    print(y.load('etl'))
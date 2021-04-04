def load_large_dta(fname):
    import pandas as pd
    import sys
 
    reader = pd.read_stata(fname,iterator=True)
    df = pd.DataFrame()
 
    try:
        chunk = reader.get_chunk(100*1000)
        while len(chunk) > 0:
            df = df.append(chunk, ignore_index=True)
            chunk = reader.get_chunk(100*1000)
            print ('.')
            sys.stdout.flush()
    except (StopIteration, KeyboardInterrupt):
        pass
 
    print('\nloaded {} rows'.format(len(df)))
 
    return df
 
 
 
def deconde_str(string):
    """
    解码 dta文件防止 乱码
    """
    re = string.encode('latin-1').decode('utf-8')
    return re
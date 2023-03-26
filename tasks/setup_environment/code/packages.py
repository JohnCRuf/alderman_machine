module_list = ['requests', 'pdfplumber', 'pandas', 'numpy', 'matplotlib', 'plotly']
#install all modules in the list, and create a text file with the name of the module and the version
import subprocess
import sys
import os
subprocess.run ([sys.executable, "-m", "pip", "install", "--upgrade", "pip"])
if os.path.exists('../output/python_packages.txt'):
    os.remove('../output/python_packages.txt')
for module in module_list:
    try:
        print('Installing ' + module)
        subprocess.check_call([sys.executable, "-m", "pip", "install", module])
        #create and overwrite a text file with the name of the module and indicating that it was installed successfully
        with open('../output/python_packages.txt', 'a') as f:
            f.write(module + ' ' + 'Installed' + '\n' )
    except:
        print('Error installing ' + module)
        with open('../output/python_packages.txt', 'a') as f:
            f.write(module + ' ' + 'Error' )


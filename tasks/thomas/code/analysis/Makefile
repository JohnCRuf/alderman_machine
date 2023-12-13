all: ../../outputs/figures/base/base.txt ../../outputs/figures/turnout/turnout.txt ../../outputs/figures/procurement/procurement.txt ../../outputs/figures/services/services.txt

../../outputs/figures/base/base.txt:
	python election_density_discont.py

../../outputs/figures/turnout/turnout.txt:
	python turnout_discont.py

../../outputs/figures/procurement/procurement.txt:
	python procurement.py

../../outputs/figures/services/services.txt:
	python services.py
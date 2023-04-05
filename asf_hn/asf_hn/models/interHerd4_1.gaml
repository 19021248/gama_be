/**
* Name: interHerd2
* Based on the internal empty template. 
* Author: HuyNQ52
* Tags: 
*/

model interHerd4_1

/* Insert your model definition here */
global {
//	float cRange <- 100.0; // 15.0;
	float cRange <-  30.0;
	int vNbContacts;
	int vNbFarmsSmallInfected <- 0;
	int vNbFarmsMediumInfected <- 0;
	int vNbFarmsLargeInfected <- 0;
	int cNbFarmsSmall <- 5499;
	int cNbFarmsMedium <- 1989;
	int cNbFarmsLarge <- 394;
//	float kContact <- 0.75;
	float kContact <- 0.5;
	init {
		/* Medium farms */
		create sFarm number: cNbFarmsMedium {
			aDispSize <- 0.6;
			location <- {rnd(2,98), rnd(2,98)};
		}
		one_of(sFarm).isInfected <- true;
		vNbFarmsMediumInfected <- vNbFarmsMediumInfected + 1;
		
		/* Small farms */
		create sFarm number: cNbFarmsSmall {
			aDispSize <- 0.3;
			location <- {rnd(2,98), rnd(2,98)};
		}
		/* Large farms */
		create sFarm number: cNbFarmsLarge {
			aDispSize <- 1.2;
			location <- {rnd(2,98), rnd(2,98)};
		}
	}
	reflex rContacts {
		write "Week: " + string(cycle);
		/* Clear contacts and Initialize new number of contacts */
		vNbContacts <- 0;
		ask sFarm {
			aListDirectSmall <- [];
			aListDirectMedium <- [];
			aListIndirectSmall <- [];
			aListIndirectMedium <- [];
			aListIndirectLarge <- [];
			aListInfected <- [];
			aListInfect <- [];
			aDirectSmall <- 0;
			aDirectMedium <- 0;
			aIndirectSmall <- 0;
			aIndirectMedium <- 0;
			aIndirectLarge <- 0;
			if (aDispSize = 0.3) {
				aDirectSmall <- poisson(0.072);		// Số lần 1 Small farm chuyển lợn sang các Small farms khác trong 1 tuần
				aIndirectSmall <- poisson(0.282);	// Số lần 1 Small farm nhận indirect contact từ các Small farms khác trong 1 tuần
				aIndirectMedium <- poisson(0.282);	// Số lần 1 Small farm nhận indirect contact từ các Medium farms trong 1 tuần
			} else if (aDispSize = 0.6) {
				aDirectSmall <- poisson(0.072); 	// Số lần 1 Medium farm chuyển lợn sang các Small farms trong 1 tuần
				aIndirectSmall <- poisson(0.282);	// Số lần 1 Medium farm nhận indirect contact từ các Small farms trong 1 tuần
				aDirectMedium <- poisson(0.073);	// Số lần 1 Medium farm chuyển lợn sang các Medium farms khác trong 1 tuần
				aIndirectMedium <- poisson(0.271);	// Số lần 1 Medium farm nhận indirect contact từ các Medium farms khác trong 1 tuần
				aIndirectLarge <- poisson(0.271);	// Số lần 1 Medium farm nhận indirect contact từ các Large farms trong 1 tuần
			} else {
				aDirectMedium <- poisson(0.073);	// Số lần 1 Large farm chuyển lợn sang các Medium farm trong 1 tuần
				aIndirectMedium <- poisson(3.5);	// Số lần 1 Large farm nhận indirect contact từ các Medium farms trong 1 tuần
				aIndirectLarge <- poisson(3.5);		// Số lần 1 Large farm nhận indirect contact từ các Large farms khác trong 1 tuần
			}
			vNbContacts <- vNbContacts + aDirectSmall + aDirectMedium + aIndirectSmall + aIndirectMedium + aIndirectLarge;
		}
		write "[Info] Number of contacts ~ " + string(vNbContacts*kContact);
		write "[Info] Number of infected: " + string(vNbFarmsSmallInfected + vNbFarmsMediumInfected + vNbFarmsLargeInfected);
		write "[Info] Number of Small infected: " + string(vNbFarmsSmallInfected);
		write "[Info] Number of Medium infected: " + string(vNbFarmsMediumInfected);
		write "[Info] Number of Large infected: " + string(vNbFarmsLargeInfected);
		
		/* Create contacts */
		ask sFarm {
			/* Direct contact to Small farm */
			int vNbLoop <- aDirectSmall - length(aListDirectSmall);
			loop times: poisson(vNbLoop*kContact) {	
				ask sFarm at_distance cRange {
					if (aDispSize = 0.3 and not(myself.aListDirectSmall contains self)) {
						add self to: myself.aListDirectSmall;
						break;
					}
				}
			}
			
			/* Direct contact to Medium farm */
			vNbLoop <- aDirectMedium - length(aListDirectMedium);
			loop times: poisson(vNbLoop*kContact) {	
				ask sFarm at_distance cRange {
					if (aDispSize = 0.6 and not(myself.aListDirectMedium contains self)) {
						add self to: myself.aListDirectMedium;
						break;
					}
				}
			}
			
			/* Get indirect contact from Small farm */
			vNbLoop <- aIndirectSmall - length(aListIndirectSmall);
			loop times: poisson(vNbLoop*kContact) {
				ask sFarm at_distance cRange {
					if (aDispSize = 0.3 and not(myself.aListIndirectSmall contains self)) {
						add self to: myself.aListIndirectSmall;
						break;
					}
				}
			}
			
			/* Get indirect contact from Medium farm */
			vNbLoop <- aIndirectMedium - length(aListIndirectMedium);
			loop times: poisson(vNbLoop*kContact) {
				ask sFarm at_distance cRange {
					if (aDispSize = 0.6 and not(myself.aListIndirectMedium contains self)) {
						add self to: myself.aListIndirectMedium;
						break;
					}
				}
			}
			
			/* Get indirect contact from Large farm */
			vNbLoop <- aIndirectLarge - length(aListIndirectLarge);
			loop times: poisson(vNbLoop*kContact) {
				ask sFarm at_distance cRange {
					if (aDispSize = 1.2 and not(myself.aListIndirectLarge contains self)) {
						add self to: myself.aListIndirectLarge;
						break;
					}
				}
			}
		}
	}
	reflex pause when: cycle = 35 {
		do pause;
	}
}

species sFarm {
	bool isInfected <- false;
	int aNbWeeks <- 0;
	float aDispSize <- 0.0;
	list<sFarm> aListDirectSmall <- [];
	list<sFarm> aListDirectMedium <- [];
	list<sFarm> aListIndirectSmall <- [];
	list<sFarm> aListIndirectMedium <- [];
	list<sFarm> aListIndirectLarge <- [];
	list<sFarm> aListInfected <- [];
	list<sFarm> aListInfect <- [];
	int aDirectSmall <- 0;
	int aDirectMedium <- 0;
	int aIndirectSmall <- 0;
	int aIndirectMedium <- 0;
	int aIndirectLarge <- 0;
	aspect default {
	    draw circle(aDispSize) color: isInfected ? #red : #green;
//		loop vFarm over: aListInfect {
//	    	draw line([location, vFarm.location]) color: #orange end_arrow:0.6;
//	    }
//	    loop vFarm over: aListInfected {
//	    	draw line([location, vFarm.location]) color: #yellow end_arrow:0.6;
//	    }
	}
	reflex rInfected {
		if !isInfected {
			loop vFarm over: aListIndirectSmall {
				if vFarm.isInfected {
					if (aDispSize != 1.2) {
						if flip(0.6) {
							isInfected <- true;
							add vFarm to: aListInfected;
							if (aDispSize = 0.3) {
								vNbFarmsSmallInfected <- vNbFarmsSmallInfected + 1;
							} else {
								vNbFarmsMediumInfected <- vNbFarmsMediumInfected + 1;
							}
							break;
						}
					} else {
						write "[Error] Large farm does not get indirect contact from Small farm";
					}
				}
			}
		}
		if !isInfected {
			loop vFarm over: aListIndirectMedium {
				if vFarm.isInfected {
					if (aDispSize != 1.2) {
						if flip(0.6) {
							isInfected <- true;
							add vFarm to: aListInfected;
							if (aDispSize = 0.3) {
								vNbFarmsSmallInfected <- vNbFarmsSmallInfected + 1;
							} else {
								vNbFarmsMediumInfected <- vNbFarmsMediumInfected + 1;
							}
							break;
						}
					} else {
						if flip(0.006) {
							isInfected <- true;
							add vFarm to: aListInfected;
							vNbFarmsLargeInfected <- vNbFarmsLargeInfected + 1;
							break;
						}
					}
				}
			}
		}
		if !isInfected {
			loop vFarm over: aListIndirectLarge {
				if vFarm.isInfected {
					if (aDispSize != 1.2) {
						if flip(0.6) {
							isInfected <- true;
							add vFarm to: aListInfected;
							if (aDispSize = 0.3) {
								vNbFarmsSmallInfected <- vNbFarmsSmallInfected + 1;
							} else {
								vNbFarmsMediumInfected <- vNbFarmsMediumInfected + 1;
							}
							break;
						}
					} else {
						if flip(0.006) {
							isInfected <- true;
							add vFarm to: aListInfected;
							vNbFarmsLargeInfected <- vNbFarmsLargeInfected + 1;
							break;
						}
					}
				}
			}
		}
	}
	
	reflex rInfect {
		if isInfected {
			loop vFarm over: aListDirectSmall {
				if !vFarm.isInfected {
					if (aDispSize != 1.2) {
						if flip(0.6) {
							vFarm.isInfected <- true;
							add vFarm to: aListInfect;
							vNbFarmsSmallInfected <- vNbFarmsSmallInfected + 1;
						}
					} else {
						write "[Error] Large farm does not direct contact to Small farm";
					}
				}
			}
			loop vFarm over: aListDirectMedium {
				if !vFarm.isInfected {
					if (aDispSize != 0.3) {
						if flip(0.6) {
							vFarm.isInfected <- true;
							add vFarm to: aListInfect;
							vNbFarmsMediumInfected <- vNbFarmsMediumInfected + 1;
						}
					} else {
						write "[Error] Small farm does not direct contact to Medium farm";
					}
				}
			}
		}
	}

}

experiment myExp type: gui {
	output {
		display myDisp {
			species sFarm aspect: default;
		}
		display myChart3 refresh: every(1 #cycles) {
			chart "Phần trăm trang trại bị nhiễm bệnh" type: series {
				data "Small" value: vNbFarmsSmallInfected/cNbFarmsSmall color: #red;
				data "Medium" value: vNbFarmsMediumInfected/cNbFarmsMedium color: #orange;
				data "Large" value: vNbFarmsLargeInfected/cNbFarmsLarge color: #green;
//				data "Culled" value: vNbFarmsCulled/cNbFarmsTotal color: #black;
			}
		}
	}
}
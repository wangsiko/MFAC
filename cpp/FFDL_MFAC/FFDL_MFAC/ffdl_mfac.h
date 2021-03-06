/**
 * @brief 全格动态线性化的无模型自适应控制
 * 
 * @file ffdl_mfac.h
 * @author huipengly
 * @date 2018-08-19
 */
#pragma once
#include <cmath>
#include <vector>
using std::vector;

class FfdlMfac
{
public:
    FfdlMfac();
    ~FfdlMfac();
    double out(double yd, double y);		//!< SISO/MISO的控制器输出
protected:
    double eta_;           					//!< η
    double mu_;            					//!< μ
    vector<double> rho_;					//!< ρ
    double lambda_;							//!< λ
    double epsilon_;						//!< ε
	vector<double> phi_init_value_;         //!< φ(1)的值
	int Ly_;
	int Lu_;

    vector<double> y_;				        //!< 实际输出值
	vector<double> dy_;						//!< 实际输出的差分
    vector<double> u_;				        //!< 控制器输出
	vector<double> du_;						//!< 控制器输出的差分
    vector<double> phi_;					//!< PPD φ的估算值，n*m维。n记录前n次的phi，每个phi有m个数
	int h_number_;							//!< h矩阵的数目
};


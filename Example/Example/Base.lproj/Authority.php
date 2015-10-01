<?php
    /// @author 田杰
    defined('BASEPATH') OR exit('No direct script access allowed');
    
    class Authority extends CI_Controller {
        
        public function login() {
            
            $account = $this->input->get_post("u");
            $password = $this->input->get_post("p");
            if (!$account || !$password) {
                $json['result'] = 0;
                $json['msg'] = "请输入帐号或密码";
                echo json_encode($json, JSON_UNESCAPED_UNICODE);
                return;
            }
            
            $user_token = md5($account."htxs.me".$password);
            setcookie("HTXS_TOKEN", $user_token, $_SERVER['REQUEST_TIME'] + 36000, '/', 'htxs.me');
            
            $json['result'] = 1;
            $json['msg'] = "登录成功，已设置Cookis";
            echo json_encode($json, JSON_UNESCAPED_UNICODE);
        }
        
        public function logout() {
            
            setcookie("HTXS_TOKEN", '', $_SERVER['REQUEST_TIME'] - 3600, '/', 'htxs.me');
            
            $json['result'] = 1;
            $json['msg'] = "退出成功，已清理Cookis";
            echo json_encode($json, JSON_UNESCAPED_UNICODE);
        }
        
    }
    ?>
package com.java_project.reggie.controller;

import com.java_project.reggie.common.R;
import lombok.extern.slf4j.Slf4j;
import org.apache.tomcat.util.http.fileupload.MultipartStream;
import org.apache.tomcat.util.http.fileupload.util.mime.MimeUtility;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ClassPathResource;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletResponse;
import java.io.*;
import java.util.UUID;

/*文件上传下载的通用控制器*/
@RequestMapping("/common")
@RestController
@Slf4j
public class CommonController {
    //定义一个通用基本地址，交给Spring自动装配
    @Value("${reggie.path}")
    private String basePath;

    @PostMapping("/upload")
    public R<String> upload(MultipartFile file){

        log.info(file.toString());
        //上传后，文件会存为临时文件，如果不转存，那么就会自动删除，所以接下来来转存
        /*
        动态路径设置
        * */

        //原始文件名
        String originalFilename = file.getOriginalFilename();
        //截取后缀名
        String suffix =originalFilename.substring(originalFilename.lastIndexOf("."));

        //使用UUID重新生成文件名，防止文件名称冲突
        String fileName  = UUID.randomUUID().toString() + suffix;
        //创建一个目录名称
        File dir =new File(basePath);
        //判断当前目录存不存在
        if(!dir.exists()){
            dir.mkdirs();
        }

        try {
            file.transferTo(new File(basePath+fileName));
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        return R.success(fileName);
    }

    //下载函数，参数为文件名称，和响应信息
    //前端发送的参数是name文件名
    @GetMapping("/download")
    public void download(String name, HttpServletResponse  response){
        //输入流，读取服务端文件内容
        FileInputStream fileInputStream = null;
        ServletOutputStream outputStream = null;
        InputStream fallbackStream = null;
        
        try {
            String fileName = name == null ? "" : name.trim();
            File file = new File(basePath + fileName);
            
            // 输出流，通过网络写回浏览器，并在浏览器展示
            response.setContentType(resolveContentType(fileName));
            outputStream = response.getOutputStream();
            
            int len = 0;
            byte[] bytes = new byte[1024];
            if (file.exists()) {
                fileInputStream = new FileInputStream(file);
                while((len = fileInputStream.read(bytes)) != -1){
                    outputStream.write(bytes, 0, len);
                    outputStream.flush();
                }
                return;
            }

            log.warn("文件不存在: {}，尝试classpath兜底", basePath + fileName);
            ClassPathResource classPathResource = new ClassPathResource("food_img/" + fileName);
            if (classPathResource.exists()) {
                fallbackStream = classPathResource.getInputStream();
                while((len = fallbackStream.read(bytes)) != -1){
                    outputStream.write(bytes, 0, len);
                    outputStream.flush();
                }
                return;
            }

            // 最终兜底图，避免前端图片404
            ClassPathResource defaultResource = new ClassPathResource("food_img/e8d26c1d-2c7c-424f-9531-49169cf96a36.jpg");
            if (defaultResource.exists()) {
                fallbackStream = defaultResource.getInputStream();
                response.setContentType("image/jpeg");
                while((len = fallbackStream.read(bytes)) != -1){
                    outputStream.write(bytes, 0, len);
                    outputStream.flush();
                }
                return;
            }

            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
        } catch (Exception e) {
            log.error("文件下载异常: {}", name, e);
        } finally {
            //关闭资源
            try {
                if (outputStream != null) outputStream.close();
                if (fileInputStream != null) fileInputStream.close();
                if (fallbackStream != null) fallbackStream.close();
            } catch (Exception e) {
                log.error("关闭流异常", e);
            }
        }
    }

    private String resolveContentType(String fileName) {
        if (fileName == null) {
            return "image/jpeg";
        }
        String lower = fileName.toLowerCase();
        if (lower.endsWith(".png")) {
            return "image/png";
        }
        if (lower.endsWith(".gif")) {
            return "image/gif";
        }
        if (lower.endsWith(".webp")) {
            return "image/webp";
        }
        return "image/jpeg";
    }
}




% Jar包编译版本：Java8
% 使用的JDK：
% openjdk version "1.8.0_422"
% OpenJDK Runtime Environment (Temurin)(build 1.8.0_422-b05)
% OpenJDK 64-Bit Server VM (Temurin)(build 25.422-b05, mixed mode)
% MATLAB_JAVA环境保证：Java8
% 应当有的环境：
% openjdk version "1.8.0_422"
% OpenJDK Runtime Environment (Temurin)(build 1.8.0_422-b05)
% OpenJDK 64-Bit Server VM (Temurin)(build 25.422-b05, mixed mode)
% 下载地址：https://adoptium.net/zh-CN/
% 下载选项：Windows x64 JDK 8
% 参考文章：https://blog.51cto.com/u_16213675/9399685
% 官方文档：https://ww2.mathworks.cn/help/compiler_sdk/gs/create-a-java-application-with-matlab-code.html
% ！！注意：Jar包的编译版本和MATLAB_JAVA的版本应当相同，已经处理好了Jar包的问题，
%           只需要使用的时候下载对应版本的JDK同时配置好MATLAB_JAVA的环境即可
%% 
% 三角形
% testpoints = [100,100;
% 200,100;
% 200,200
% ];
% 正方形
% testpoints = [100,100;300,100;300,300;100,300;100,130];
% 八字型
% testpoints = [100,100;200,150;300,100;300,300;200,250;100,300;100,180];
% 三环
% testpoints = [100,100;200,150;300,100;400,150;500,100;500,300;400,250;300,300;200,250;100,300;100,130]
% tunnel型
% testpoints = [100,100;
% 170,150;
% 240,150;
% 300,100;
% 360,150;
% 430,150;
% 500,100;
% 500,300;
% 430,250;
% 360,250;
% 300,300;
% 240,250;
% 170,250;
% 100,300];
%星型
% testpoints = [50,200;
% 200,250;
% 250,300;
% 300,250;
% 450,200;
% 300,150;
% 250,100;
% 200,150];

%%
% clear java;
% javarmpath("polygon-offset-algorithm.jar");
% javaaddpath("polygon-offset-algorithm.jar");
% javaclasspath;
%%
% function shrinkHull_test(testpoints,distance)
%     % 导入Java类
%     import com.lee.algorithm.OffsetAlgorithm;
%     import com.lee.entity.Point;
%     
%     % 创建点对象
%     points = java.util.ArrayList();
%     for i = 1:size(testpoints,1)
%         points.add(Point(testpoints(i,1), testpoints(i,2)));
%     end
%     
%     %调用子函数，输出结果
%     %输出结果类型为cell
%     %对于分块间有一个单独的cell元素[0,0]用于分隔
%     result = shrinkHull(points,distance);
%     
%     %处理并绘制
%     for i = 1:size(result,1)
%         flag=true;
%         if result{i}(1,1)==0&&result{i}(1,2)==0
%             flag = false;
%             continue
%         elseif flag && i>2 && result{i-1}(1,1)==0
%             plot([result{i-2}(end,1),result{i}(1,1)],[result{i-2}(end,2),result{i}(1,2)],'k');
%         elseif flag && i>1
%             plot([result{i-1}(end,1),result{i}(1,1)],[result{i-1}(end,2),result{i}(1,2)],'k');
%         end
%         plot(result{i}(:,1),result{i}(:,2),'k');
%         hold on;
%     end
% end
function result=shrinkHull_Interface(testpoints,distance)
    % 导入Java类
    import com.lee.algorithm.OffsetAlgorithm;
    import com.lee.entity.Point;
    
    % 创建点对象
    points = java.util.ArrayList();
    for i = 1:size(testpoints,1)
        points.add(Point(testpoints(i,1), testpoints(i,2)));
    end
    
    %调用子函数，输出结果
    %输出结果类型为cell
    %对于分块间有一个单独的cell元素[0,0]用于分隔
    result = shrinkHull(points,distance);
end

function result=shrinkHull(inputPoints,distance)
    import com.lee.algorithm.OffsetAlgorithm;
    import com.lee.entity.Point;
    result = {};

    % 进行内缩处理，获得新的点集
    newPointsCell = OffsetAlgorithm.offsetAlgorithm(inputPoints, distance);
    disp(newPointsCell);
    % 检查是否有多个分块
    if isempty(newPointsCell)
        % 如果没有产生新的轮廓，返回空
        return
    elseif newPointsCell.size()>1
        temp={};
        for w=0:newPointsCell.size()-1
            newPoints = newPointsCell.get(w);
            offset = [];
            for k = 0:newPoints.size()-1
                point = newPoints.get(k);
                x=double(point.getX());
                y=double(point.getY());
                % 存储新的轮廓
                offset = [offset; x,y];
            end
            if ~isempty(offset)
                temp{end+1,1}=offset;
            end
        end
        % 处理每个分块
        for w=0:newPointsCell.size()-1
           block_result=shrinkHull(newPointsCell.get(w),distance);
           result{end+1,1}=[0,0];
           result{end+1,1}=temp{w+1};
           for m=1:size(block_result,1)
               disp(block_result{m});
           end
           % 将每个分块加入到结果中
           for k=1:size(block_result,1)
               result{end+1,1}=block_result{k};
           end
           for m=1:size(result,1)
               disp(result{m});
           end
        end      
    else
        % 处理单一轮廓的情况
        newPoints = newPointsCell.get(0);
        if isempty(newPoints)
            disp('No valid contour generated.');
        else
            offset = [];
            for k = 0:newPoints.size()-1
                point = newPoints.get(k);
                x=double(point.getX());
                y=double(point.getY());
                % 存储新的轮廓
                offset = [offset; x,y];
            end
            if ~isempty(offset)
                result{end+1,1}=offset;
                disp(offset);
            end

            % 递归调用继续内缩当前新轮廓
            block_result = shrinkHull(newPoints, distance);  
            for k = 1:size(block_result, 1)
                result{end+1, 1} = block_result{k};
            end
        end
    end
end



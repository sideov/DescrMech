classdef app2_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure             matlab.ui.Figure
        Image                matlab.ui.control.Image
        hCheckBox            matlab.ui.control.CheckBox
        l0cell               matlab.ui.control.NumericEditField
        l0Label              matlab.ui.control.Label
        SpeedSlider          matlab.ui.control.Slider
        SpeedSliderLabel     matlab.ui.control.Label
        ResetButton          matlab.ui.control.Button
        gcell                matlab.ui.control.NumericEditField
        gLabel               matlab.ui.control.Label
        dtcell               matlab.ui.control.NumericEditField
        dtLabel              matlab.ui.control.Label
        Ncell                matlab.ui.control.NumericEditField
        NEditFieldLabel      matlab.ui.control.Label
        gammacell            matlab.ui.control.NumericEditField
        gammaEditFieldLabel  matlab.ui.control.Label
        bettacell            matlab.ui.control.NumericEditField
        bettaEditFieldLabel  matlab.ui.control.Label
        kcell                matlab.ui.control.NumericEditField
        kEditFieldLabel      matlab.ui.control.Label
        mcell                matlab.ui.control.NumericEditField
        mEditFieldLabel      matlab.ui.control.Label
        DropButton           matlab.ui.control.Button
        StopButton           matlab.ui.control.Button
        StartButton          matlab.ui.control.Button
        dy_axis              matlab.ui.control.UIAxes
        GraphAxis            matlab.ui.control.UIAxes
        MainAxis             matlab.ui.control.UIAxes
    end


    properties (Access = private)
        g
        m
        k
        gamma
        betta
        N
        t_max = 100000
        a = -1
        b = 1
        cur_step = 1
        y
        u
        X
        l0
        dt
        num_steps
        flag
        V
        drop = false
        ball_v
        Acc_right
        V_right
        ball
        started
        y_ball
        h
        changing_rate = 1;
        PLT;
        lgd_Graph
        dy = []
        ball_drop = []
        i_dropped
        dy_hist = [];







    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, das)

            app.y = @(x) 10*x^2 - 10;

            

            app.i_dropped = 0;

%             legend(app.GraphAxis, "a", 'AutoUpdate','off');
%             legend(app.dy_axis, "dy", 'AutoUpdate','off');
%             set(groot,'defaultLegendAutoUpdate','off')

               

        end

        % Callback function
        function UITableCellSelection(app, event)

        end

        % Callback function
        function StartButtonPushed(app, event)

        end

        % Button pushed function: StartButton
        function StartButtonPushed2(app, event)
            app.PrepareToStart();

            app.draw();
        end

        function PrepareToStart(app)
            app.g = app.gcell.Value;
            app.m = app.mcell.Value;
            app.k = app.kcell.Value;
            app.gamma = app.gammacell.Value;
            app.betta = app.bettacell.Value;
            app.N = app.Ncell.Value;
            app.dt = app.dtcell.Value;

            app.X = linspace(app.a,app.b,app.N);
            app.u.x = [];
            app.u.y = [];
            app.V.x = zeros(2,app.N);
            app.V.y = zeros(2,app.N);
            app.ball_v = 0;
            app.Acc_right = [];
            app.V_right = [];
            app.ball_drop = [];
            app.ball.time = [];
            app.y_ball = 0;
            app.dy = [];
            app.i_dropped = 0;
            app.cur_step = 1;
            app.flag = true;
            app.StopButton.Text = "Stop";
%             app.GraphAxis.Legend.String = "acc";
%             app.dy_axis.Legend.String = "dy";


            app.num_steps = app.t_max/app.dt;
            app.changing_rate = app.SpeedSlider.Value;
            cla(app.MainAxis)
            cla(app.GraphAxis)
            cla(app.dy_axis)


            for ind = 1:app.N
                app.u.x = [app.u.x; app.X(ind)];
                app.u.y = [app.u.y; app.y(app.X(ind))];
            end

            %plot(app.MainAxis, app.u.x, app.u.y, "r")


            if app.hCheckBox.Value == 1
                app.l0 = app.l0cell.Value;
            else
                app.l0 = sqrt((app.u.y(2) - app.u.y(1))^2 + (app.u.x(2)-app.u.x(1))^2)/2;
                app.l0cell.Value = app.l0;
            end

            plot(app.MainAxis, app.u.x, app.u.y, 'ro--');
            app.MainAxis.YLimMode = "auto";

        end



        function draw(app)
%             app.h_graph = animatedline(app.GraphAxis, [0], [0], "Color", "red", "Marker", "o");
%             app.h_dx = animatedline(app.dy_axis, [0], [0], "Color", "blue", "Marker", "o");


            for i = app.cur_step:app.num_steps
                if app.flag
                    app.cur_step = app.cur_step + 1;

                    for ind = 1:app.N
                        if ind == 1
                            app.V.x(i+1,ind) = 0;app.GraphAxis
                            app.V.y(i+1,ind) = 0;

                        elseif ind == app.N

                            if app.drop == false
                                app.V.x(i+1,ind) = 0;
                                app.V.y(i+1,ind) = 0;
                            else

                                lL = sqrt((app.u.x(ind) - app.u.x(ind-1))^2 + (app.u.y(ind)-app.u.y(ind-1))^2);

                                if lL > app.l0
                                    FL = -(lL - app.l0) * app.k;
                                else
                                    FL = 0;

                                end

                                F.x = (app.u.x(ind) - app.u.x(ind-1))*FL/lL;
                                F.y = (app.u.y(ind) - app.u.y(ind-1))*FL/lL - app.m*app.g;


                                frxL = ((app.V.x(i, ind-1)-app.V.x(i, ind))*(app.u.x(ind-1)-app.u.x(ind))+(app.V.y(i, ind-1)-app.V.y(i, ind))*(app.u.y(ind-1)-app.u.y(ind)))/lL * (app.u.x(ind-1) - app.u.x(ind));
                                fryL = ((app.V.x(i, ind-1)-app.V.x(i, ind))*(app.u.x(ind-1)-app.u.x(ind))+(app.V.y(i, ind-1)-app.V.y(i, ind))*(app.u.y(ind-1)-app.u.y(ind)))/lL * (app.u.y(ind-1) - app.u.y(ind));

                                app.V.x(i+1,ind) = app.V.x(i,ind) + (F.x - app.gamma*app.V.x(i, ind) + app.betta*frxL)/app.m*app.dt;
                                app.V.y(i+1,ind) = app.V.y(i,ind) + (F.y - app.gamma*app.V.y(i, ind) + app.betta*fryL)/app.m*app.dt;

                                app.ball_v = app.ball_v - (app.g - app.betta*app.ball_v)*app.dt;



                                a_right = sqrt((F.x/app.m)^2 + (F.y/app.m)^2);
                                v_right = sqrt((app.V.x(i,ind))^2 + (app.V.y(i,ind))^2);


                                app.Acc_right = [app.Acc_right, a_right];
                                app.V_right = [app.V_right, v_right];

                                if app.i_dropped == 0
                                    app.i_dropped = i;
                                end

                                app.ball_drop = [app.ball_drop, (i-app.i_dropped)*app.dt];

                                app.y_ball = app.y_ball + app.ball_v*app.dt;

                                app.dy = [app.dy, (app.y_ball-app.u.y(app.N))];

                                


                            end

                        else

                            lR = sqrt((app.u.x(ind) - app.u.x(ind+1))^2 + (app.u.y(ind)-app.u.y(ind+1))^2);
                            lL = sqrt((app.u.x(ind) - app.u.x(ind-1))^2 + (app.u.y(ind)-app.u.y(ind-1))^2);

                            if lR > app.l0
                                FR = -(lR - app.l0) * app.k;
                            else
                                FR = 0;
                            end

                            if lL > app.l0
                                FL = -(lL - app.l0) * app.k;
                            else
                                FL = 0;
                            end


                            frxR = ((app.V.x(i, ind+1)-app.V.x(i, ind))*(app.u.x(ind+1)-app.u.x(ind))+(app.V.y(i, ind+1)-app.V.y(i, ind))*(app.u.y(ind+1)-app.u.y(ind)))/lR * (app.u.x(ind+1) - app.u.x(ind));
                            fryR = ((app.V.x(i, ind+1)-app.V.x(i, ind))*(app.u.x(ind+1)-app.u.x(ind))+(app.V.y(i, ind+1)-app.V.y(i, ind))*(app.u.y(ind+1)-app.u.y(ind)))/lR * (app.u.y(ind+1) - app.u.y(ind));

                            frxL = ((app.V.x(i, ind-1)-app.V.x(i, ind))*(app.u.x(ind-1)-app.u.x(ind))+(app.V.y(i, ind-1)-app.V.y(i, ind))*(app.u.y(ind-1)-app.u.y(ind)))/lL * (app.u.x(ind-1) - app.u.x(ind));
                            fryL = ((app.V.x(i, ind-1)-app.V.x(i, ind))*(app.u.x(ind-1)-app.u.x(ind))+(app.V.y(i, ind-1)-app.V.y(i, ind))*(app.u.y(ind-1)-app.u.y(ind)))/lL * (app.u.y(ind-1) - app.u.y(ind));

                            stx = (frxR + frxL);
                            sty = (fryR + fryL);


                            F.x = (app.u.x(ind) - app.u.x(ind+1))/lR*FR + (app.u.x(ind) - app.u.x(ind-1))*FL/lL - app.gamma*app.V.x(i, ind) + app.betta*stx;
                            F.y = (app.u.y(ind) - app.u.y(ind+1))/lR*FR + (app.u.y(ind) - app.u.y(ind-1))*FL/lL - app.gamma*app.V.y(i,ind) + app.betta*sty - app.m*app.g;

                            app.V.x(i+1,ind) = app.V.x(i,ind) + F.x/app.m*app.dt;
                            app.V.y(i+1,ind) = app.V.y(i,ind) + F.y/app.m*app.dt;

                        end

                    end


                    %absV = sum((app.V.x(i+1, :).*(app.V.y(i+1, :))).^2);
                    %app.EditField.Value = absV;


                    app.u.x = app.u.x + app.V.x(i+1, :)'*app.dt;
                    app.u.y = app.u.y + app.V.y(i+1, :)'*app.dt;


                    hold(app.MainAxis, "off");

                    %app.h.addpoints(app.u.x, app.u.y)

                    

                    if mod(app.cur_step, app.changing_rate) == 0
                        plot(app.MainAxis, app.u.x, app.u.y, 'ro-');

%                         app.PLT.XData = app.u.x;
%                         app.PLT.YData = app.u.y;

                        app.MainAxis.YLim = [min(app.u.y)-1,max(app.u.y)+1];
                        axis(app.MainAxis, "equal")

                        hold(app.MainAxis, "on");



                        if app.drop == true

                            ball_x = app.b + 0.1;

                            plot(app.MainAxis, ball_x, app.y_ball, 'go');

                            plot(app.GraphAxis, app.ball_drop, app.Acc_right/app.g, "r");

                            plot(app.dy_axis, app.ball_drop, app.dy, "b");

                            right_border = app.ball_drop(end)+1;

                            axis(app.GraphAxis, [max([right_border-5, app.ball_drop(1)]), right_border, 0, max([app.Acc_right(1)/app.g+1, max(app.Acc_right./app.g)*1.1])]);

                            axis(app.dy_axis, [max([right_border-5, app.ball_drop(1)]), right_border, 0, max(app.dy(1)*1.1+0.1, max(app.dy)*1.1)])
                           
                        end

                        drawnow;


                        %clearpoints(app.h)
                    end


                else
                    break


                end



            end




        end

        % Value changed function: mcell
        function mcellValueChanged(app, event)
            value = app.mcell.Value;
            app.m = value;
        end

        % Value changed function: Ncell
        function NcellValueChanged(app, event)
            value = app.Ncell.Value;
            app.N = value;
        end

        % Value changed function: dtcell
        function dtcellValueChanged(app, event)
            value = app.dtcell.Value;
            app.dt = value;

        end

        % Value changed function: gcell
        function gcellValueChanged(app, event)
            value = app.gcell.Value;
            app.g = value;

        end

        % Value changed function: gammacell
        function gammacellValueChanged(app, event)
            value = app.gammacell.Value;
            app.gamma = value;
        end

        % Value changed function: kcell
        function kcellValueChanged(app, event)
            value = app.kcell.Value;
            app.k = value;
        end

        % Value changed function: bettacell
        function bettacellValueChanged(app, event)
            value = app.bettacell.Value;
            app.betta = value;
        end

        % Button pushed function: StopButton
        function StopButtonPushed(app, event)
            if app.StopButton.Text == "Continue"
                app.StopButton.Text = "Stop";
                app.flag = true;
                app.draw();
            else
                app.StopButton.Text = "Continue";
                app.flag = false;



            end
        end

        % Button pushed function: ResetButton
        function ResetButtonPushed(app, event)
            app.g = app.gcell.Value;
            app.m = app.mcell.Value;
            app.k = app.kcell.Value;
            app.gamma = app.gammacell.Value;
            app.betta = app.bettacell.Value;
            app.N = app.Ncell.Value;
            app.dt = app.dtcell.Value;
            app.StopButton.Text = "Stop";

            app.X = linspace(app.a,app.b,app.N);
            app.u.x = [];
            app.u.y = [];
            app.V.x = zeros(2,app.N);
            app.V.y = zeros(2,app.N);
            app.ball_v = 0;
            app.Acc_right = [];
            app.V_right = [];
            app.ball.time = [];
            app.ball_drop = [];
            app.y_ball = 0;
            app.cur_step = 1;
            app.i_dropped = 0;
            app.flag = true;
            app.drop = false;
            app.num_steps = app.t_max/app.dt;
            app.changing_rate = 1;
            app.SpeedSlider.Value = 1;
            app.dy = [];

            cla(app.MainAxis)
            cla(app.GraphAxis)
            cla(app.dy_axis)





            for ind = 1:app.N
                app.u.x = [app.u.x; app.X(ind)];
                app.u.y = [app.u.y; app.y(app.X(ind))];
            end

            %plot(app.MainAxis, app.u.x, app.u.y, "r")

            if app.hCheckBox.Value == 1
                app.l0 = app.l0cell.Value;
            else
                app.l0 = sqrt((app.u.y(2) - app.u.y(1))^2 + (app.u.x(2)-app.u.x(1))^2)/2;
                app.l0cell.Value = app.l0;
            end


            plot(app.MainAxis, app.u.x, app.u.y, 'ro--');
            axis(app.MainAxis, "auto")



        end

        % Button pushed function: DropButton
        function DropButtonPushed(app, event)
            app.drop = true;
            app.gammacell.Value = 0;
            app.bettacell.Value = 0;
            app.gamma = 0;
            app.betta = 0;

%             app.GraphAxis.Legend.String = "acc";
%             app.dy_axis.Legend.String = "dy";
        end

        % Value changed function: SpeedSlider
        function SpeedSliderValueChanged(app, event)
            value = app.SpeedSlider.Value;
            % determine which discrete option the current value is closest to.
            [~, minIdx] = min(abs(value - event.Source.MajorTicks(:)));
            % move the slider to that option
            event.Source.Value = event.Source.MajorTicks(minIdx);
            % Override the selected value if you plan on using it within this function
            value = event.Source.MajorTicks(minIdx);

            app.changing_rate = value;
        end

        % Value changed function: l0cell
        function l0cellValueChanged(app, event)
            value = app.l0cell.Value;
            if app.hCheckBox.Value == 0
                app.l0 = app.l0;
            elseif app.hCheckBox.Value == 1
                app.l0 = value;
            end

        end

        % Value changed function: hCheckBox
        function hCheckBoxValueChanged(app, event)
            value = app.hCheckBox.Value;

        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Color = [1 1 1];
            app.UIFigure.Position = [100 100 870 783];
            app.UIFigure.Name = 'UI Figure';

            % Create MainAxis
            app.MainAxis = uiaxes(app.UIFigure);
            title(app.MainAxis, 'Цепочка на подвесах')
            xlabel(app.MainAxis, 'X')
            ylabel(app.MainAxis, 'Y')
            app.MainAxis.XGrid = 'on';
            app.MainAxis.YGrid = 'on';
            app.MainAxis.Box = 'on';
            app.MainAxis.Position = [8 354 857 430];

            % Create GraphAxis
            app.GraphAxis = uiaxes(app.UIFigure);
            title(app.GraphAxis, {'График зависимости относительного (от g) ускорения'; 'крайней правой частицы от времени'})
            xlabel(app.GraphAxis, 'time')
            ylabel(app.GraphAxis, 'acceleration')
            app.GraphAxis.XGrid = 'on';
            app.GraphAxis.YGrid = 'on';
            app.GraphAxis.Box = 'on';
            app.GraphAxis.Position = [9 115 423 240];

            % Create dy_axis
            app.dy_axis = uiaxes(app.UIFigure);
            title(app.dy_axis, {'Расстояние между свободно падающим телом и'; ' крайним правым элементом цепочки'})
            xlabel(app.dy_axis, 'time')
            ylabel(app.dy_axis, 'dy')
            app.dy_axis.XGrid = 'on';
            app.dy_axis.YGrid = 'on';
            app.dy_axis.Box = 'on';
            app.dy_axis.Position = [443 115 423 240];

            % Create StartButton
            app.StartButton = uibutton(app.UIFigure, 'push');
            app.StartButton.ButtonPushedFcn = createCallbackFcn(app, @StartButtonPushed2, true);
            app.StartButton.Position = [31 72 100 22];
            app.StartButton.Text = 'Start';

            % Create StopButton
            app.StopButton = uibutton(app.UIFigure, 'push');
            app.StopButton.ButtonPushedFcn = createCallbackFcn(app, @StopButtonPushed, true);
            app.StopButton.Position = [31 42 100 22];
            app.StopButton.Text = 'Stop';

            % Create DropButton
            app.DropButton = uibutton(app.UIFigure, 'push');
            app.DropButton.ButtonPushedFcn = createCallbackFcn(app, @DropButtonPushed, true);
            app.DropButton.Position = [31 12 100 22];
            app.DropButton.Text = 'Drop';

            % Create mEditFieldLabel
            app.mEditFieldLabel = uilabel(app.UIFigure);
            app.mEditFieldLabel.HorizontalAlignment = 'right';
            app.mEditFieldLabel.Position = [271 72 25 22];
            app.mEditFieldLabel.Text = 'm';

            % Create mcell
            app.mcell = uieditfield(app.UIFigure, 'numeric');
            app.mcell.ValueChangedFcn = createCallbackFcn(app, @mcellValueChanged, true);
            app.mcell.Position = [311 72 50 22];
            app.mcell.Value = 1;

            % Create kEditFieldLabel
            app.kEditFieldLabel = uilabel(app.UIFigure);
            app.kEditFieldLabel.HorizontalAlignment = 'right';
            app.kEditFieldLabel.Position = [272 42 25 22];
            app.kEditFieldLabel.Text = 'k';

            % Create kcell
            app.kcell = uieditfield(app.UIFigure, 'numeric');
            app.kcell.ValueChangedFcn = createCallbackFcn(app, @kcellValueChanged, true);
            app.kcell.Position = [312 42 49 22];
            app.kcell.Value = 100;

            % Create bettaEditFieldLabel
            app.bettaEditFieldLabel = uilabel(app.UIFigure);
            app.bettaEditFieldLabel.HorizontalAlignment = 'right';
            app.bettaEditFieldLabel.Position = [261 12 33 22];
            app.bettaEditFieldLabel.Text = 'betta';

            % Create bettacell
            app.bettacell = uieditfield(app.UIFigure, 'numeric');
            app.bettacell.ValueChangedFcn = createCallbackFcn(app, @bettacellValueChanged, true);
            app.bettacell.Position = [309 12 52 22];

            % Create gammaEditFieldLabel
            app.gammaEditFieldLabel = uilabel(app.UIFigure);
            app.gammaEditFieldLabel.HorizontalAlignment = 'right';
            app.gammaEditFieldLabel.Position = [391 76 46 22];
            app.gammaEditFieldLabel.Text = 'gamma';

            % Create gammacell
            app.gammacell = uieditfield(app.UIFigure, 'numeric');
            app.gammacell.ValueChangedFcn = createCallbackFcn(app, @gammacellValueChanged, true);
            app.gammacell.Position = [452 76 39 22];
            app.gammacell.Value = 0.5;

            % Create NEditFieldLabel
            app.NEditFieldLabel = uilabel(app.UIFigure);
            app.NEditFieldLabel.HorizontalAlignment = 'right';
            app.NEditFieldLabel.Position = [412 46 25 22];
            app.NEditFieldLabel.Text = 'N';

            % Create Ncell
            app.Ncell = uieditfield(app.UIFigure, 'numeric');
            app.Ncell.ValueChangedFcn = createCallbackFcn(app, @NcellValueChanged, true);
            app.Ncell.Position = [452 46 39 22];
            app.Ncell.Value = 21;

            % Create dtLabel
            app.dtLabel = uilabel(app.UIFigure);
            app.dtLabel.HorizontalAlignment = 'right';
            app.dtLabel.Position = [411 16 25 22];
            app.dtLabel.Text = 'dt';

            % Create dtcell
            app.dtcell = uieditfield(app.UIFigure, 'numeric');
            app.dtcell.ValueChangedFcn = createCallbackFcn(app, @dtcellValueChanged, true);
            app.dtcell.Position = [451 16 39 22];
            app.dtcell.Value = 0.1;

            % Create gLabel
            app.gLabel = uilabel(app.UIFigure);
            app.gLabel.HorizontalAlignment = 'right';
            app.gLabel.Position = [503 77 25 22];
            app.gLabel.Text = 'g';

            % Create gcell
            app.gcell = uieditfield(app.UIFigure, 'numeric');
            app.gcell.ValueChangedFcn = createCallbackFcn(app, @gcellValueChanged, true);
            app.gcell.Position = [543 77 39 22];
            app.gcell.Value = 1;

            % Create ResetButton
            app.ResetButton = uibutton(app.UIFigure, 'push');
            app.ResetButton.ButtonPushedFcn = createCallbackFcn(app, @ResetButtonPushed, true);
            app.ResetButton.Position = [141 72 100 22];
            app.ResetButton.Text = 'Reset';

            % Create SpeedSliderLabel
            app.SpeedSliderLabel = uilabel(app.UIFigure);
            app.SpeedSliderLabel.HorizontalAlignment = 'right';
            app.SpeedSliderLabel.Position = [594 48 40 22];
            app.SpeedSliderLabel.Text = 'Speed';

            % Create SpeedSlider
            app.SpeedSlider = uislider(app.UIFigure);
            app.SpeedSlider.Limits = [1 100];
            app.SpeedSlider.ValueChangedFcn = createCallbackFcn(app, @SpeedSliderValueChanged, true);
            app.SpeedSlider.MinorTicks = [];
            app.SpeedSlider.Position = [546 46 150 3];
            app.SpeedSlider.Value = 1;

            % Create l0Label
            app.l0Label = uilabel(app.UIFigure);
            app.l0Label.HorizontalAlignment = 'right';
            app.l0Label.Position = [622 77 25 22];
            app.l0Label.Text = 'l0';

            % Create l0cell
            app.l0cell = uieditfield(app.UIFigure, 'numeric');
            app.l0cell.ValueChangedFcn = createCallbackFcn(app, @l0cellValueChanged, true);
            app.l0cell.Position = [658 77 39 22];
            app.l0cell.Value = 1;

            % Create hCheckBox
            app.hCheckBox = uicheckbox(app.UIFigure);
            app.hCheckBox.ValueChangedFcn = createCallbackFcn(app, @hCheckBoxValueChanged, true);
            app.hCheckBox.Text = '';
            app.hCheckBox.Position = [609 77 25 22];

            % Create Image
            app.Image = uiimage(app.UIFigure);
            app.Image.Position = [734 16 100 100];
            app.Image.ImageSource = 'logo_vert.png';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = app2_exported(varargin)

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
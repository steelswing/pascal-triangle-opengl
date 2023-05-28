{$reference System.Windows.Forms.dll}
{$reference System.Drawing.dll}

program triangle;

uses System.Windows.Forms;
uses System;
uses OpenGL;
uses OpenGLABC;
uses Common;

var simpleShader: gl_program;

procedure init();
begin
    simpleShader := InitProgram(InitShader('simple.vs.glsl', ShaderType.VERTEX_SHADER));
end;

type Tessellator = class
  private
       vertIndex : integer;
       currentColor := new Vec3f(1, 1, 1);
       vertices := new Vec3f[100];
       colors := new Vec3f[100];
  public
    constructor create();
    begin
    end;
    
    procedure draw(shader: gl_program);
    begin
      // pos buffer
      var vertex_pos_buffer: gl_buffer;
      begin
        gl.CreateBuffers(1, vertex_pos_buffer);
        gl.NamedBufferData(vertex_pos_buffer, new IntPtr(vertIndex * sizeof(Vec3f)), vertices, VertexBufferObjectUsage.STATIC_DRAW);
              
        var attribute_position := gl.GetAttribLocation(shader, 'position');
        gl.VertexAttribFormat(attribute_position, 3, VertexAttribType.FLOAT, false, 0);
        gl.BindVertexBuffer(attribute_position, vertex_pos_buffer, IntPtr.Zero, sizeof(Vec3f));
        gl.EnableVertexAttribArray(attribute_position);
      end;
      
      // color buffer
      var vertex_clr_buffer: gl_buffer;
      begin
        gl.CreateBuffers(1, vertex_clr_buffer);
        gl.NamedBufferData(vertex_clr_buffer, new IntPtr(vertIndex * sizeof(Vec3f)), colors, VertexBufferObjectUsage.STATIC_DRAW);
        
        var attribute_color := gl.GetAttribLocation(shader, 'color');
        gl.VertexAttribFormat(attribute_color, 3, VertexAttribType.FLOAT, false, 0);
        gl.BindVertexBuffer(attribute_color, vertex_clr_buffer, IntPtr.Zero, sizeof(Vec3f));
        gl.EnableVertexAttribArray(attribute_color);
      end;
      
      gl.DrawArrays(PrimitiveType.TRIANGLES, 0, vertIndex);
      
      gl.DeleteBuffers(1, vertex_pos_buffer);
      gl.DeleteBuffers(1, vertex_clr_buffer);
    end;

          
    procedure setColor(r: real; g: real; b: real);
    begin
      currentColor := new Vec3f(r, g, b);
    end;
          
    procedure addVertex(x: real; y: real; z: real);
    begin
      vertices[vertIndex] := new Vec3f(x, y, z);
      colors[vertIndex] := currentColor;
      vertIndex := vertIndex + 1;
    end;
  
  end;
 
procedure render();
begin  
  var tess := new Tessellator();
  
  tess.setColor(1, 0, 0);
  tess.addVertex(-0.5, -0.5, 0);
  
  tess.setColor(0, 1, 0);
  tess.addVertex(0.5, -0.5, 0);
  
  tess.setColor(0, 0, 1);
  tess.addVertex(0.0, 0.5, 0);
  
  gl.UseProgram(simpleShader);
  tess.draw(simpleShader);
end;

procedure RedrawProc(pl: PlatformLoader; EndFrame: ()->());
begin
  gl := new OpenGL.gl(pl);
  init();
  while true do
  begin
    // очищаем окно в начале перерисовки
    gl.Clear(ClearBufferMask.COLOR_BUFFER_BIT or ClearBufferMask.DEPTH_BUFFER_BIT);
    render();
    
    // получаем тип последней ошибки
    var err := gl.GetError;
    // и если ошибка есть - выводим её
    if err <> ErrorCode.NO_ERROR then 
      Writeln(err);
    
    gl.Finish;
    // EndFrame меняет местами буферы и ждёт vsync
    EndFrame;
  end;
end;

procedure createWindow();
begin
  // Создаём и настраиваем окно
  var f := new Form;
  f.StartPosition := FormStartPosition.CenterScreen;
  f.ClientSize := new System.Drawing.Size(800, 500);
  f.FormBorderStyle := FormBorderStyle.Fixed3D;
  
  // Если окно закрылось - надо сразу завершить программу
  // Иначе поток перерисовки продолжит пытаться рисовать на закрытом окне
  f.Closed += (o, e)-> Halt();
  
  // Настраиваем поверхность рисования
  var hdc := OpenGLABC.gl_gdi.InitControl(f);
  
  // Настраиваем перерисовку
  f.Load += (o, e)-> OpenGLABC.RedrawHelper.SetupRedrawThread(hdc, RedrawProc);
  Application.Run(f);
end;


begin
  createWindow();
end.
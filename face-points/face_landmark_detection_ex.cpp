#include <dlib/image_processing/frontal_face_detector.h>
#include <dlib/image_processing/render_face_detections.h>
#include <dlib/image_processing.h>
#include <dlib/gui_widgets.h>
#include <dlib/image_io.h>
#include <iostream>

using namespace dlib;
using namespace std;

int main(int argc, char** argv)
{  
    try
    {
        frontal_face_detector detector = get_frontal_face_detector();
        shape_predictor sp;
        deserialize(argv[1]) >> sp;

        // image_window win, win_faces;
        // cout << "processing image " << argv[2] << endl;
        array2d<rgb_pixel> img;
        load_image(img, argv[2]);

        // pyramid_up(img);
        std::vector<rectangle> dets = detector(img);

        // cout << "Number of faces detected: " << dets.size() << endl;

        // std::vector<full_object_detection> shapes;

        // for (unsigned long j = 0; j < dets.size(); ++j)
        // {
            full_object_detection shape = sp(img, dets[0]);
            // cout << "number of parts: "<< shape.num_parts() << endl;
            // shapes.push_back(shape); 
            for( int i = 0; i < 68; i++){
                cout << shape.part(i).x() << " " << shape.part(i).y() << " ";
            }
        // }

        // Now let's view our face poses on the screen.
        // win.clear_overlay();
        // win.set_image(img);
        // win.add_overlay(render_face_detections(shapes));

        // // We can also extract copies of each face that are cropped, rotated upright,
        // // and scaled to a standard size as shown here:
        // dlib::array<array2d<rgb_pixel> > face_chips;
        // extract_image_chips(img, get_face_chip_details(shapes), face_chips);
        // win_faces.set_image(tile_images(face_chips));
        // cin.get();
    }
    catch (exception& e)
    {
        cout << "\nexception thrown!" << endl;
        cout << e.what() << endl;
    }
}
